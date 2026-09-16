import assert from "node:assert/strict";
import { once } from "node:events";
import { after, before, test } from "node:test";

import { createApp } from "../dist/app.js";

let server;
let baseUrl;

before(async () => {
  process.env.APP_VERSION = "test-version";
  server = createApp().listen(0, "127.0.0.1");
  await once(server, "listening");

  const address = server.address();
  assert.notEqual(address, null);
  assert.equal(typeof address, "object");
  baseUrl = `http://127.0.0.1:${address.port}`;
});

after(async () => {
  await new Promise((resolve, reject) => {
    server.close((error) => (error ? reject(error) : resolve()));
  });
});

test("GET /health reports readiness", async () => {
  const response = await fetch(`${baseUrl}/health`);

  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), { status: "ok" });
});

test("GET /api/hello returns application and instance information", async () => {
  const response = await fetch(`${baseUrl}/api/hello?name=Terraform`);
  const body = await response.json();

  assert.equal(response.status, 200);
  assert.equal(body.message, "Hola, Terraform");
  assert.equal(body.version, "test-version");
  assert.equal(typeof body.host, "string");
  assert.equal(typeof body.timestamp, "string");
});

test("unknown routes return a JSON 404", async () => {
  const response = await fetch(`${baseUrl}/does-not-exist`);

  assert.equal(response.status, 404);
  assert.deepEqual(await response.json(), { error: "not_found" });
});
