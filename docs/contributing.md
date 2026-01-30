# Contributing

## Workflow
1.  **Fork & Clone**: Standard GitHub workflow.
2.  **Branching**: `feature/name` or `bugfix/issue-id`.
3.  **PRs**: Require 1 approval. CI must pass.

## Coding Standards
*   **Style**: Standard Java conventions. 4-space indentation.
*   **Structure**: 
    *   Servlets in `com.nettenz.ebay.servlet`
    *   DAOs in `com.nettenz.ebay.dao`
*   **Docs**: Javadoc required for all public methods explaining *why*, not just *what*.

## Development
*   **Build**: `mvn clean install`
*   **Test**: `mvn test` (JUnit 5)
*   **Local Run**: `mvn tomcat7:run` or deploy WAR to local Tomcat.
