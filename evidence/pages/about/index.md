---
title: about
---

This project is built by [Jacob Matson](https://twitter.com/matsonj). The objective of the project is to see what can be done with a mono-repo approach the modern data stack, hence "MDS in a box." In the time since the initial write up post published on the [duckDB blog](https://duckdb.org/2022/10/12/modern-data-stack-in-a-box.html), a few bits have been added:
 - [devcontainer support](https://containers.dev/) for an improved development experience.
 - docker support for ease of deployment (although ironically not used to deploy the project into netlify).
 - replaced superset with [evidence](https://evidence.dev) for fully managed viz in code.
 - auto build in github actions