import fs from 'fs/promises';
import path from 'path';

import openapiTemplate from '../openapi.json';

type BuildOpenApiSpecOptions = {
  port?: number | string | undefined;
  serverUrl?: string | undefined;
};

type OpenApiSpec = typeof openapiTemplate;

const clone = <T>(v: T): T => JSON.parse(JSON.stringify(v)) as T;

export const buildOpenApiSpec = (options: BuildOpenApiSpecOptions = {}): OpenApiSpec => {
  const port = options.port ?? process.env.PORT ?? 3000;
  const serverUrl = options.serverUrl ?? `http://localhost:${port}`;

  const spec = clone(openapiTemplate);
  spec.servers = [{ url: `${serverUrl}/api` }];
  return spec;
};

export const generateOpenapiJson = async (options: BuildOpenApiSpecOptions = {}) => {
  const spec = buildOpenApiSpec(options);
  const outputPath = path.join(__dirname, '../openapi.json');
  await fs.writeFile(outputPath, JSON.stringify(spec, null, 2));
  console.log(`OpenAPI spec generated at: ${outputPath}`);
};

