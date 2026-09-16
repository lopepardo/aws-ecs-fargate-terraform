import { randomUUID } from "node:crypto";
import { hostname } from "node:os";
import express, {
  type ErrorRequestHandler,
  type RequestHandler,
} from "express";

const requestLogger: RequestHandler = (request, response, next) => {
  const requestId = request.header("x-request-id") ?? randomUUID();
  const startedAt = process.hrtime.bigint();

  response.setHeader("x-request-id", requestId);
  response.on("finish", () => {
    if (request.path === "/health") {
      return;
    }

    const durationMs = Number(process.hrtime.bigint() - startedAt) / 1_000_000;

    console.log(
      JSON.stringify({
        level: "info",
        requestId,
        method: request.method,
        path: request.originalUrl,
        statusCode: response.statusCode,
        durationMs: Number(durationMs.toFixed(2)),
      }),
    );
  });

  next();
};

const errorHandler: ErrorRequestHandler = (error, request, response, _next) => {
  console.error(
    JSON.stringify({
      level: "error",
      method: request.method,
      path: request.originalUrl,
      message: error instanceof Error ? error.message : "Unknown error",
    }),
  );

  if (error instanceof SyntaxError) {
    response.status(400).json({ error: "invalid_json" });
    return;
  }

  response.status(500).json({ error: "internal_server_error" });
};

export function createApp(): express.Express {
  const app = express();

  app.disable("x-powered-by");
  app.use(express.json({ limit: "1mb" }));
  app.use(requestLogger);

  app.get("/health", (_request, response) => {
    response.status(200).json({ status: "ok" });
  });

  app.get("/", (_request, response) => {
    response.json({
      name: "ecs-alb-api",
      version: process.env.APP_VERSION ?? "unversioned",
      appEnvironment: process.env.APP_ENV ?? "development",
      host: hostname(),
    });
  });

  app.get("/api/hello", (request, response) => {
    const requestedName = request.query.name;
    const name =
      typeof requestedName === "string" && requestedName.trim().length > 0
        ? requestedName.trim().slice(0, 60)
        : "mundo";

    response.json({
      message: `Hola, ${name}`,
      version: process.env.APP_VERSION ?? "unversioned",
      appEnvironment: process.env.APP_ENV ?? "development",
      host: hostname(),
      timestamp: new Date().toISOString(),
    });
  });

  app.use((_request, response) => {
    response.status(404).json({ error: "not_found" });
  });

  app.use(errorHandler);

  return app;
}
