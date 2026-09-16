import { createApp } from "./app.js";

const port = Number.parseInt(process.env.PORT ?? "3000", 10);

if (!Number.isInteger(port) || port < 1 || port > 65_535) {
  throw new Error(`Invalid PORT: ${process.env.PORT ?? "3000"}`);
}

const server = createApp().listen(port, "0.0.0.0", () => {
  console.log(
    JSON.stringify({
      level: "info",
      message: "API listening",
      port,
      version: process.env.APP_VERSION ?? "development",
    }),
  );
});

let shuttingDown = false;

function shutdown(signal: NodeJS.Signals) {
  if (shuttingDown) {
    return;
  }

  shuttingDown = true;
  console.log(JSON.stringify({ level: "info", message: "Shutting down", signal }));

  const forcedExit = setTimeout(() => {
    console.error(JSON.stringify({ level: "error", message: "Forced shutdown" }));
    process.exit(1);
  }, 25_000);
  forcedExit.unref();

  server.close((error) => {
    clearTimeout(forcedExit);

    if (error) {
      console.error(error);
      process.exit(1);
    }

    process.exit(0);
  });
}

process.on("SIGTERM", shutdown);
process.on("SIGINT", shutdown);
