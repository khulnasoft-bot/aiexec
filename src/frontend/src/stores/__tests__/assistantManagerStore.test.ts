/**
 * Tests for assistantManagerStore (undo/redo, flow management, UI state).
 *
 * Documents real bugs with it.failing():
 * - undo/redo push mutable references (L101-103, L122-125)
 * - resetStore does not clear undo/redo history (L148-155)
 */

import type {
  AllNodeType,
  EdgeType,
  FlowType,
  NodeDataType,
} from "@/types/flow";

// Mock flowStore before importing the store under test
const mockSetNodes = jest.fn();
const mockSetEdges = jest.fn();
const mockResetFlow = jest.fn();
const mockFlowStoreState = {
  nodes: [] as AllNodeType[],
  edges: [] as EdgeType[],
  setNodes: mockSetNodes,
  setEdges: mockSetEdges,
  resetFlow: mockResetFlow,
};

jest.mock("@/stores/flowStore", () => ({
  __esModule: true,
  default: {
    getState: () => mockFlowStoreState,
  },
}));

import useAssistantManagerStore from "../assistantManagerStore";

// Helper to create a minimal FlowType
function createFlow(id: string, name = `Flow ${id}`): FlowType {
  return {
    id,
    name,
    data: { nodes: [], edges: [] },
  } as FlowType;
}

function makeNode(id: string, data?: Record<string, unknown>): AllNodeType {
  return {
    id,
    type: "genericNode",
    position: { x: 0, y: 0 },
    data: (data ?? {}) as NodeDataType,
  } as AllNodeType;
}

function makeEdge(id: string): EdgeType {
  return { id, source: "", target: "" } as EdgeType;
}

beforeEach(() => {
  // Reset store state
  useAssistantManagerStore.setState({
    currentFlowId: "",
    currentFlow: undefined,
    flows: undefined,
    assistantSidebarOpen: false,
    isFullscreen: false,
    isLoading: false,
    selectedFlowsComponentsCards: [],
    selectedCompData: undefined,
    examples: [],
    newAssistantChat: false,
    selectedSession: undefined,
    healthCheckMaxRetries: 5,
  });

  // Reset mock flow store state
  mockFlowStoreState.nodes = [];
  mockFlowStoreState.edges = [];
  mockSetNodes.mockClear();
  mockSetEdges.mockClear();
  mockResetFlow.mockClear();
});

describe("initial state", () => {
  it("should initialize with default values", () => {
    const state = useAssistantManagerStore.getState();

    expect(state.currentFlowId).toBe("");
    expect(state.currentFlow).toBeUndefined();
    expect(state.flows).toBeUndefined();
    expect(state.assistantSidebarOpen).toBe(false);
    expect(state.isFullscreen).toBe(false);
    expect(state.isLoading).toBe(false);
  });
});

describe("UI state", () => {
  it("should set assistantSidebarOpen", () => {
    useAssistantManagerStore.getState().setAssistantSidebarOpen(true);
    expect(useAssistantManagerStore.getState().assistantSidebarOpen).toBe(true);

    useAssistantManagerStore.getState().setAssistantSidebarOpen(false);
    expect(useAssistantManagerStore.getState().assistantSidebarOpen).toBe(
      false,
    );
  });

  it("should set isFullscreen", () => {
    useAssistantManagerStore.getState().setFullscreen(true);
    expect(useAssistantManagerStore.getState().isFullscreen).toBe(true);
  });
});

describe("setCurrentFlow", () => {
  it("should update currentFlow and currentFlowId", () => {
    const flow = createFlow("flow-1");
    useAssistantManagerStore.getState().setCurrentFlow(flow);

    const state = useAssistantManagerStore.getState();
    expect(state.currentFlow).toEqual(flow);
    expect(state.currentFlowId).toBe("flow-1");
  });

  it("should set currentFlowId to empty string when flow undefined", () => {
    useAssistantManagerStore.getState().setCurrentFlow(createFlow("f1"));
    useAssistantManagerStore.getState().setCurrentFlow(undefined);

    expect(useAssistantManagerStore.getState().currentFlowId).toBe("");
  });

  it("should close sidebar when changing flows", () => {
    useAssistantManagerStore.getState().setAssistantSidebarOpen(true);
    useAssistantManagerStore.getState().setCurrentFlow(createFlow("new"));

    expect(useAssistantManagerStore.getState().assistantSidebarOpen).toBe(
      false,
    );
  });

  it("should call resetFlow on flow change", () => {
    const flow = createFlow("f1");
    useAssistantManagerStore.getState().setCurrentFlow(flow);

    expect(mockResetFlow).toHaveBeenCalledWith(flow);
  });
});

describe("setFlows", () => {
  it("should update currentFlow from new flows array", () => {
    // Set current flow id first
    useAssistantManagerStore.setState({ currentFlowId: "f2" });

    const flows = [createFlow("f1"), createFlow("f2"), createFlow("f3")];
    useAssistantManagerStore.getState().setFlows(flows);

    const state = useAssistantManagerStore.getState();
    expect(state.flows).toHaveLength(3);
    expect(state.currentFlow?.id).toBe("f2");
  });

  it("should set currentFlow undefined when id not in flows", () => {
    useAssistantManagerStore.setState({ currentFlowId: "nonexistent" });

    useAssistantManagerStore.getState().setFlows([createFlow("f1")]);

    expect(useAssistantManagerStore.getState().currentFlow).toBeUndefined();
  });
});

describe("getFlowById", () => {
  it("should return flow by id", () => {
    const flows = [createFlow("a"), createFlow("b")];
    useAssistantManagerStore.setState({ flows });

    const result = useAssistantManagerStore.getState().getFlowById("b");
    expect(result?.id).toBe("b");
  });

  it("should return undefined for non-existent id", () => {
    useAssistantManagerStore.setState({ flows: [createFlow("a")] });

    const result = useAssistantManagerStore.getState().getFlowById("z");
    expect(result).toBeUndefined();
  });

  it("should return undefined when flows is undefined", () => {
    useAssistantManagerStore.setState({ flows: undefined });

    const result = useAssistantManagerStore.getState().getFlowById("a");
    expect(result).toBeUndefined();
  });
});

describe("undo/redo", () => {
  // Use unique flow IDs per test to avoid module-level past/future crosstalk
  let testFlowId: string;
  let testCounter = 0;

  beforeEach(() => {
    testCounter++;
    testFlowId = `undo-test-flow-${testCounter}-${Date.now()}`;
    useAssistantManagerStore.setState({ currentFlowId: testFlowId });
  });

  it("should save state to past on takeSnapshot", () => {
    mockFlowStoreState.nodes = [makeNode("n1")];
    mockFlowStoreState.edges = [makeEdge("e1")];

    useAssistantManagerStore.getState().takeSnapshot();

    // After snapshot, undo should restore the saved state
    mockFlowStoreState.nodes = [makeNode("n2")];
    mockFlowStoreState.edges = [];

    useAssistantManagerStore.getState().undo();

    expect(mockSetNodes).toHaveBeenCalledWith([makeNode("n1")]);
    expect(mockSetEdges).toHaveBeenCalledWith([makeEdge("e1")]);
  });

  it("should clear future on new snapshot", () => {
    // Create initial state, snapshot, modify, undo to create future
    mockFlowStoreState.nodes = [makeNode("original")];
    useAssistantManagerStore.getState().takeSnapshot();

    mockFlowStoreState.nodes = [makeNode("modified")];
    useAssistantManagerStore.getState().takeSnapshot();

    useAssistantManagerStore.getState().undo();

    // Now take a new snapshot — future should be cleared
    mockFlowStoreState.nodes = [makeNode("new-path")];
    useAssistantManagerStore.getState().takeSnapshot();

    // Redo should do nothing since future is cleared
    mockSetNodes.mockClear();
    useAssistantManagerStore.getState().redo();
    expect(mockSetNodes).not.toHaveBeenCalled();
  });

  it("should not duplicate identical snapshots", () => {
    mockFlowStoreState.nodes = [makeNode("same")];
    mockFlowStoreState.edges = [];

    useAssistantManagerStore.getState().takeSnapshot();
    useAssistantManagerStore.getState().takeSnapshot(); // Same state — should skip

    // Only one undo should be possible
    mockFlowStoreState.nodes = [makeNode("different")];
    useAssistantManagerStore.getState().undo();

    mockSetNodes.mockClear();
    useAssistantManagerStore.getState().undo();
    expect(mockSetNodes).not.toHaveBeenCalled();
  });

  it("should cap history to maxHistorySize", () => {
    for (let i = 0; i < 105; i++) {
      mockFlowStoreState.nodes = [makeNode(`n${i}`)];
      mockFlowStoreState.edges = [];
      useAssistantManagerStore.getState().takeSnapshot();
    }

    // Count how many undos are possible (should be <= 100)
    let undoCount = 0;
    for (let i = 0; i < 110; i++) {
      mockSetNodes.mockClear();
      useAssistantManagerStore.getState().undo();
      if (mockSetNodes.mock.calls.length > 0) {
        undoCount++;
      } else {
        break;
      }
    }

    expect(undoCount).toBeLessThanOrEqual(100);
  });

  it("should restore nodes/edges on undo", () => {
    mockFlowStoreState.nodes = [makeNode("before")];
    mockFlowStoreState.edges = [makeEdge("edge-before")];
    useAssistantManagerStore.getState().takeSnapshot();

    mockFlowStoreState.nodes = [makeNode("after")];
    mockFlowStoreState.edges = [makeEdge("edge-after")];

    useAssistantManagerStore.getState().undo();

    expect(mockSetNodes).toHaveBeenCalledWith([makeNode("before")]);
    expect(mockSetEdges).toHaveBeenCalledWith([makeEdge("edge-before")]);
  });

  it("should restore nodes/edges on redo", () => {
    mockFlowStoreState.nodes = [makeNode("state1")];
    useAssistantManagerStore.getState().takeSnapshot();

    mockFlowStoreState.nodes = [makeNode("state2")];
    useAssistantManagerStore.getState().takeSnapshot();

    // Undo back to state1
    useAssistantManagerStore.getState().undo();
    mockSetNodes.mockClear();

    // Redo should restore state2
    useAssistantManagerStore.getState().redo();
    expect(mockSetNodes).toHaveBeenCalled();
  });

  it("should do nothing on undo with empty past", () => {
    useAssistantManagerStore.getState().undo();

    expect(mockSetNodes).not.toHaveBeenCalled();
    expect(mockSetEdges).not.toHaveBeenCalled();
  });

  it("should do nothing on redo with empty future", () => {
    useAssistantManagerStore.getState().redo();

    expect(mockSetNodes).not.toHaveBeenCalled();
    expect(mockSetEdges).not.toHaveBeenCalled();
  });

  it("should scope history per flow id", () => {
    // Flow A: take snapshot
    useAssistantManagerStore.setState({ currentFlowId: "flowA" });
    mockFlowStoreState.nodes = [makeNode("A-node")];
    useAssistantManagerStore.getState().takeSnapshot();

    // Flow B: take snapshot
    useAssistantManagerStore.setState({ currentFlowId: "flowB" });
    mockFlowStoreState.nodes = [makeNode("B-node")];
    useAssistantManagerStore.getState().takeSnapshot();

    // Undo in flow B should get B's state, not A's
    mockFlowStoreState.nodes = [makeNode("B-modified")];
    useAssistantManagerStore.getState().undo();
    expect(mockSetNodes).toHaveBeenCalledWith([makeNode("B-node")]);

    // Switch to flow A — undo should get A's state
    mockSetNodes.mockClear();
    useAssistantManagerStore.setState({ currentFlowId: "flowA" });
    mockFlowStoreState.nodes = [makeNode("A-modified")];
    useAssistantManagerStore.getState().undo();
    expect(mockSetNodes).toHaveBeenCalledWith([makeNode("A-node")]);
  });
});

describe("resetStore", () => {
  it("should reset state fields", () => {
    useAssistantManagerStore.setState({
      flows: [createFlow("f1")],
      currentFlow: createFlow("f1"),
      currentFlowId: "f1",
      selectedFlowsComponentsCards: ["c1"],
    });

    useAssistantManagerStore.getState().resetStore();

    const state = useAssistantManagerStore.getState();
    expect(state.flows).toEqual([]);
    expect(state.currentFlow).toBeUndefined();
    expect(state.currentFlowId).toBe("");
    expect(state.selectedFlowsComponentsCards).toEqual([]);
  });
});

describe("bugs and edge cases", () => {
  let bugFlowId: string;
  let bugCounter = 0;

  beforeEach(() => {
    bugCounter++;
    bugFlowId = `bug-test-flow-${bugCounter}-${Date.now()}`;
    useAssistantManagerStore.setState({ currentFlowId: bugFlowId });
  });

  it.failing("BUG: undo should cloneDeep before pushing to future — mutable refs corrupt history", () => {
    // L101-103: future[currentFlowId].push({ nodes: newState.nodes, edges: newState.edges })
    // This pushes a REFERENCE to the live flowStore state. If nodes/edges are later mutated,
    // the future entry is silently corrupted.
    mockFlowStoreState.nodes = [makeNode("n1", { value: "original" })];
    mockFlowStoreState.edges = [];
    useAssistantManagerStore.getState().takeSnapshot();

    // Modify state and take another snapshot
    mockFlowStoreState.nodes = [makeNode("n2", { value: "second" })];
    useAssistantManagerStore.getState().takeSnapshot();

    // Undo — this pushes current state to future WITHOUT cloneDeep
    useAssistantManagerStore.getState().undo();

    // Now mutate the nodes array that was pushed to future
    mockFlowStoreState.nodes[0] = makeNode("mutated", { value: "corrupted" });

    // Redo should restore the state from BEFORE mutation
    mockSetNodes.mockClear();
    useAssistantManagerStore.getState().redo();

    // The redo state should be { id: "n2" }, NOT the mutated version
    const restoredNodes = mockSetNodes.mock.calls[0][0];
    expect(restoredNodes[0].id).toBe("n2");
    expect(restoredNodes[0].data.value).toBe("second");
  });

  it.failing("BUG: redo should cloneDeep before pushing to past — mutable refs corrupt history", () => {
    // L122-125: past[currentFlowId].push({ nodes: newState.nodes, edges: newState.edges })
    // Same bug as undo — pushes live references instead of deep copies.
    mockFlowStoreState.nodes = [makeNode("n1")];
    mockFlowStoreState.edges = [];
    useAssistantManagerStore.getState().takeSnapshot();

    mockFlowStoreState.nodes = [makeNode("n2")];
    useAssistantManagerStore.getState().takeSnapshot();

    mockFlowStoreState.nodes = [makeNode("n3")];
    useAssistantManagerStore.getState().takeSnapshot();

    // Undo twice
    useAssistantManagerStore.getState().undo();
    useAssistantManagerStore.getState().undo();

    // Redo — pushes current state to past WITHOUT cloneDeep
    useAssistantManagerStore.getState().redo();

    // Mutate the live nodes
    mockFlowStoreState.nodes[0] = makeNode("corrupted");

    // Undo should restore the state from before mutation
    mockSetNodes.mockClear();
    useAssistantManagerStore.getState().undo();

    const restoredNodes = mockSetNodes.mock.calls[0][0];
    expect(restoredNodes[0].id).not.toBe("corrupted");
  });

  it.failing("BUG: resetStore should clear undo/redo history for the current flow", () => {
    // L148-155: resetStore sets currentFlowId to "" but does NOT clear
    // the module-level `past` and `future` objects. If the user re-opens
    // the same flow, stale undo/redo history from before the reset persists.
    const flowId = bugFlowId;

    mockFlowStoreState.nodes = [makeNode("before-reset")];
    mockFlowStoreState.edges = [];
    useAssistantManagerStore.getState().takeSnapshot();

    useAssistantManagerStore.getState().resetStore();

    // Restore the same flow id — simulating re-opening the same flow
    useAssistantManagerStore.setState({ currentFlowId: flowId });

    // After reset + re-open, undo should do nothing — history should be cleared
    mockSetNodes.mockClear();
    useAssistantManagerStore.getState().undo();
    expect(mockSetNodes).not.toHaveBeenCalled();
  });
});
