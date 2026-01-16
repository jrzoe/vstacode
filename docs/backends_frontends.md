# Backends and frontends for big data in R and Python

When working with particularly large datasets, base R data frames and pandas in Python will become painfully slow. Furthermore, some tables are truly just too large to load into memory. While you *can* request very large amounts of memory on a slurm job (assuming you're on a compute cluster), it will likely take a very long time to be assigned and will steal away resources from other users. Fortunately, there are a number of high-performance backends that can drastically speed up your data wrangling and analysis, some of which also support out-of-memory workflows. I had known of a lot of these backends for a while, but I never wanted to put the time into learning their own APIs (I wanted to use DuckDB, but I didn't know how to make SQL queries). Fortunately, I discovered there some great frontends that allow you to use these backends with a single API. No more learning multiple syntaxes for a single problem that you will then forget!

I'll outline some really helpful backends for R and Python, followed by a frontend for each language that allows you to use a single API across multiple them.

## Language-specific backends

### data.table (R)

[data.table](https://rdatatable.gitlab.io/data.table/) is a fast package for working with tabular data in R. I've been using this more or less since day one of my PhD, and it's great. It's particularly well-suited for large in-memory data frames, offering significant speed improvements over base R. data.table supports parallelization out of the box and uses a concise syntax. If you're working with millions of rows and need to stay in R, data.table is a great choice. The downside is the syntax can be a bit tricky to learn at first. I was the only one in my group every using it regularly, meaning my code was not very accessible to others.

### polars (Python)

[Polars](https://pola.rs/) is a fast DataFrame library for Python, written in Rust. Like data.table in R, polars is designed for high-performance in-memory data manipulation. It supports parallelization natively, unlike Pandas. Polars also offers a lazy evaluation mode, which optimizes query execution before running. If pandas is slowing you down, polars is a worthy alternative. But again, most people are using Pandas, so it can be a barrier to collaboration if others aren't familiar with the syntax.

## Language-agnostic backends

### Arrow

[Apache Arrow](https://arrow.apache.org/) is a cross-language development platform for in-memory and on-disk columnar data. Arrow provides a standardized format for columnar data that can be shared across languages (R, Python, Julia, etc). For working with big data, Arrow is particularly useful for its ability to work out-of-memory by streaming data from disk. Arrow's Parquet file format is also highly efficient for storing and reading large datasets, and it can maintain type information for data.

### DuckDB

[DuckDB](https://duckdb.org/) is an in-process SQL database designed for analytical queries. DuckDB is extremely fast on large datasets and supports streaming data from files without loading them entirely into memory. This makes it ideal for querying and manipulating those extra large tables. DuckDB integrates seamlessly with both R and Python, and can read directly from Parquet, CSV, and other file formats. However, you'd need to learn SQL to use it out of the box.

## Frontends for backend-agnostic workflows

While these backends offer tremendous performance benefits, learning a new syntax for each is a huge barrier. I find staying fresh on Python and R syntax generally is more than enough work; learning multiple new APIs for data manipulation/transformation backends in each isn't an option. However, each can offer quite a lot depending on the task, so finding a way to use them easily would be nice. Fortunately, there are frontends that let you use a single, familiar API while leveraging different backends under the hood.

I think a big point to watch out for with frontends is that they stay in active development and are widely used. If not, you may find yourself stuck with a frontend that doesn't support the latest features of a backend you want to use, or worse, becomes unmaintained. Fortunately, the two I mention below are quite active, lots of stars on GitHub and are frequently updated. They seem to be the most popular options in their respective languages.

### tidyverse ecosystem (R)

The tidyverse offers several packages that translate dplyr syntax to different backends:

- **dtplyr**: Translates dplyr code to data.table, giving you the tidyverse syntax with data.table performance.
- **dbplyr**: Translates dplyr code to SQL, allowing you to work with databases (including DuckDB) using familiar tidyverse verbs.
- **arrow**: The arrow R package integrates with dplyr, enabling you to use dplyr syntax on Arrow datasets for out-of-memory workflows.

This means you can write your code once in dplyr and switch backends depending on your needs—data.table for speed on in-memory data, dbplyr for database queries, or arrow for streaming large files.

### narwhals (Python)

[Narwhals](https://github.com/narwhals-dev/narwhals) is a lightweight Python library that provides a unified API across multiple DataFrame backends, including pandas, polars, arrow, and others. The goal is to write code once and have it run efficiently on whichever backend you choose, functioning similarly to the three pacakges I mentioned above for R. Of note, I don't think narwhals fully supports DuckDB yet, but arrow should have you covered for out-of-memory workflows.