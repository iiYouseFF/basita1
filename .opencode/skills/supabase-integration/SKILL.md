---
name: supabase-integration
description: Manages Supabase PostgreSQL schemas, RLS policies, and Dart repository integration.
---

# Supabase Integration Workflow

When creating database tables or queries:

1. **Schema Check via Supabase MCP**:
   - Inspect table structures, primary keys, and foreign key relationships.

2. **Security**:
   - Always ensure Row Level Security (RLS) is enabled on new tables.
   - Generate SQL migration snippets for needed policy changes (e.g., `CREATE POLICY "Users can access own rows"`).

3. **Dart Client Service**:
   - Write strongly-typed service calls using `Supabase.instance.client`.
   - Wrap remote calls in `try-catch` blocks returning `Either<Failure, T>` or custom results.