import react from "@vitejs/plugin-react-swc";
import * as dotenv from "dotenv";
import path from "path";
import { defineConfig, loadEnv } from "vite";
import svgr from "vite-plugin-svgr";
import tsconfigPaths from "vite-tsconfig-paths";
import {
  API_ROUTES,
  BASENAME,
  PORT,
  PROXY_TARGET,
} from "./src/customization/config-constants";

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), "");

  const envPrimeagentResult = dotenv.config({
    path: path.resolve(__dirname, "../../.env"),
  });

  const envPrimeagent = envPrimeagentResult.parsed || {};

  const apiRoutes = API_ROUTES || ["^/api/v1/", "^/api/v2/", "/health"];

  const target =
    env.VITE_PROXY_TARGET || PROXY_TARGET || "http://localhost:7860";

  const port = Number(env.VITE_PORT) || PORT || 3000;

  const proxyTargets = apiRoutes.reduce((proxyObj, route) => {
    proxyObj[route] = {
      target: target,
      changeOrigin: true,
      secure: false,
      ws: true,
    };
    return proxyObj;
  }, {});

  return {
    base: BASENAME || "",
    build: {
      outDir: "build",
      chunkSizeWarningLimit: 1000,
      rollupOptions: {
        output: {
          manualChunks: (id) => {
            if (id.includes("node_modules")) {
              if (id.includes("@tanstack/react-query")) {
                return "tanstack";
              }
              if (id.includes("@radix-ui")) {
                return "radix";
              }
              if (id.includes("react") || id.includes("react-dom")) {
                return "react";
              }
              if (id.includes("@xyflow/react") || id.includes("reactflow")) {
                return "flow";
              }
              if (id.includes("ag-grid")) {
                return "ag-grid";
              }
              if (id.includes("ace-builds") || id.includes("react-ace")) {
                return "editor";
              }
              if (id.includes("framer-motion")) {
                return "motion";
              }
              return "vendor";
            }
          },
        },
      },
    },
    define: {
      "import.meta.env.BACKEND_URL": JSON.stringify(
        envPrimeagent.BACKEND_URL ?? "http://localhost:7860",
      ),
      "import.meta.env.ACCESS_TOKEN_EXPIRE_SECONDS": JSON.stringify(
        envPrimeagent.ACCESS_TOKEN_EXPIRE_SECONDS ?? 60,
      ),
      "import.meta.env.CI": JSON.stringify(envPrimeagent.CI ?? false),
      "import.meta.env.PRIMEAGENT_AUTO_LOGIN": JSON.stringify(
        envPrimeagent.PRIMEAGENT_AUTO_LOGIN ?? true,
      ),
      "import.meta.env.PRIMEAGENT_MCP_COMPOSER_ENABLED": JSON.stringify(
        envPrimeagent.PRIMEAGENT_MCP_COMPOSER_ENABLED ?? "true",
      ),
    },
    plugins: [react(), svgr(), tsconfigPaths()],
    server: {
      port: port,
      proxy: {
        ...proxyTargets,
      },
    },
  };
});
