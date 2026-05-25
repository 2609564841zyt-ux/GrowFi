type SupabaseRequest = {
  method?: "GET" | "POST" | "PATCH" | "DELETE";
  table: string;
  query?: string;
  body?: unknown;
};

const url = process.env.SUPABASE_URL;
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

export function hasSupabaseConfig() {
  return Boolean(url && serviceRoleKey);
}

export async function supabaseRequest<T>({ method = "GET", table, query = "", body }: SupabaseRequest): Promise<T> {
  if (!url || !serviceRoleKey) {
    throw new Error("Missing Supabase configuration");
  }

  const endpoint = `${url}/rest/v1/${table}${query}`;
  const response = await fetch(endpoint, {
    method,
    headers: {
      apikey: serviceRoleKey,
      Authorization: `Bearer ${serviceRoleKey}`,
      "Content-Type": "application/json",
      Prefer: method === "POST" ? "return=representation" : "return=representation"
    },
    body: body ? JSON.stringify(body) : undefined,
    cache: "no-store"
  });

  if (!response.ok) {
    const message = await response.text();
    throw new Error(`Supabase ${method} ${table} failed: ${message}`);
  }

  return response.json() as Promise<T>;
}
