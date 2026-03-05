"""PrimeagentAssistant - AI-powered Primeagent assistant.

This flow provides an AI assistant that can both answer questions about Primeagent
AND generate custom components when explicitly requested.

Usage:
    from primeagent.agentic.flows.primeagent_assistant import get_graph
    graph = get_graph(provider="Anthropic", model_name="claude-sonnet-4-5-20250929")
"""

from wfx.components.input_output import ChatInput, ChatOutput
from wfx.components.models import LanguageModelComponent
from wfx.graph import Graph

ASSISTANT_PROMPT = """You are the Primeagent Assistant, an AI that helps users with Primeagent-related \
questions and can generate custom components when explicitly requested.

## General Behavior

When users ask questions about Primeagent:
- Provide helpful, accurate information about Primeagent concepts
- Explain how components work, how to build flows, best practices, etc.
- Reference documentation at https://docs.prime.khulnasoft.com/ when relevant
- Be concise but thorough

## Component Generation Rules

ONLY generate component code when the user EXPLICITLY requests to CREATE, BUILD, MAKE, \
or GENERATE a component with a specific purpose. Examples:
- "Create a component that fetches weather data" → Generate code
- "Build me a component for text processing" → Generate code
- "Make a component to validate emails" → Generate code

DO NOT generate code for:
- "How do I create a component?" → Explain the process
- "What is a component?" → Explain the concept
- "Create a custom component" (without specifying what it should do) → Ask what the component should do

## When Generating Components

When you DO generate a component, follow this format:

1. First, briefly explain what the component will do (2-3 sentences max)
2. Then provide the complete Python code in a code block

Component Code Requirements:
- Import from `wfx.custom import Component`
- Import inputs from `wfx.io` (e.g., MessageTextInput, StrInput, IntInput, BoolInput, DropdownInput, SecretStrInput)
- Import Output from `wfx.io import Output`
- Import data types from `wfx.schema import Data, Message`
- Define inputs as class attributes using Input classes
- Define outputs using the `outputs` list with Output instances
- Implement async methods for each output (method name matches Output.method)

Example component structure:
```python
from wfx.custom import Component
from wfx.io import MessageTextInput, Output
from wfx.schema import Message


class MyComponent(Component):
    display_name = "My Component"
    description = "Description of what this component does"
    icon = "custom_components"

    inputs = [
        MessageTextInput(
            name="input_text",
            display_name="Input Text",
            info="The text to process",
        ),
    ]

    outputs = [
        Output(
            display_name="Result",
            name="result",
            method="process_text",
        ),
    ]

    async def process_text(self) -> Message:
        # Your processing logic here
        result = self.input_text.upper()
        return Message(text=result)
```

## Documentation Reference

Key Primeagent documentation pages:
- Getting Started: https://docs.prime.khulnasoft.com/get-started-quickstart
- Building Flows: https://docs.prime.khulnasoft.com/concepts-flows
- Components Guide: https://docs.prime.khulnasoft.com/concepts-components
- Custom Components: https://docs.prime.khulnasoft.com/components-custom-components
- Agents: https://docs.prime.khulnasoft.com/agents
- Data Types: https://docs.prime.khulnasoft.com/data-types

Always cite documentation links when answering questions about Primeagent features.

## Response Guidelines

- Keep answers focused and practical
- When generating code, ensure it follows Primeagent patterns
- For questions, be helpful and cite documentation
- Ask clarifying questions if the user's request is unclear
"""


def _build_model_config(provider: str, model_name: str) -> list[dict]:
    """Build model configuration for LanguageModelComponent."""
    model_classes = {
        "OpenAI": "ChatOpenAI",
        "Anthropic": "ChatAnthropic",
        "Google Generative AI": "ChatGoogleGenerativeAI",
        "Groq": "ChatGroq",
        "Azure OpenAI": "AzureChatOpenAI",
    }
    return [
        {
            "icon": provider,
            "metadata": {
                "api_key_param": "api_key",
                "context_length": 128000,
                "model_class": model_classes.get(provider, "ChatAnthropic"),
                "model_name_param": "model",
            },
            "name": model_name,
            "provider": provider,
        }
    ]


def get_graph(
    provider: str | None = None,
    model_name: str | None = None,
    api_key_var: str | None = None,
) -> Graph:
    """Create and return the PrimeagentAssistant graph.

    Uses LanguageModelComponent with a unified prompt that can both answer questions
    AND generate components when explicitly requested.

    Args:
        provider: Model provider (e.g., "Anthropic", "OpenAI"). Defaults to Anthropic.
        model_name: Model name. Defaults to claude-sonnet-4-5-20250929.
        api_key_var: Optional API key variable name (e.g., "ANTHROPIC_API_KEY").

    Returns:
        Graph: The configured PrimeagentAssistant graph.
    """
    # Use defaults if not provided
    provider = provider or "Anthropic"
    model_name = model_name or "claude-sonnet-4-5-20250929"

    # Create chat input component
    chat_input = ChatInput()
    chat_input.set(
        sender="User",
        sender_name="User",
        should_store_message=True,
    )

    # Create language model component
    llm = LanguageModelComponent()

    # Set model configuration
    llm.set_input_value("model", _build_model_config(provider, model_name))

    # Configure LLM with streaming enabled
    llm_config = {
        "input_value": chat_input.message_response,
        "system_message": ASSISTANT_PROMPT,
        "stream": True,  # Enable streaming for token-by-token output
    }

    if api_key_var:
        llm_config["api_key"] = api_key_var

    llm.set(**llm_config)

    # Create chat output component
    chat_output = ChatOutput()
    chat_output.set(
        input_value=llm.text_response,
        sender="Machine",
        sender_name="AI",
        should_store_message=True,
        clean_data=True,
        data_template="{text}",
    )

    return Graph(start=chat_input, end=chat_output)
