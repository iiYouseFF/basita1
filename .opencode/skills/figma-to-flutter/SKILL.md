---
name: figma-to-flutter
description: Extracts Figma frame properties and converts them into production-ready Flutter widgets.
---

# Figma to Flutter Widget Conversion Guide

When converting a Figma design frame to Flutter:

1. **Extract Specs via Figma MCP**:
   - Query the Figma node using the provided File Key and Node ID.
   - Read vector shapes, auto-layout constraints, padding, border radius, and typography.

2. **Map Design Tokens**:
   - Colors -> Map hex colors to `Theme.of(context).colorScheme` or `AppColors`.
   - Typography -> Map font weights and sizes to `TextTheme`.
   - Auto-Layout -> Convert horizontal/vertical layouts to `Row`, `Column`, `Flex`, or `Wrap` with explicit `MainAxisAlignment` and `CrossAxisAlignment`.

3. **Code Requirements**:
   - Return clean, modular Flutter `StatelessWidget` or `StatefulWidget` instances.
   - Never hardcode raw hex colors directly into widgets; use app theme constants.
   - Use `SizedBox` for spacing corresponding to Figma gap values.