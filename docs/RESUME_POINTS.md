# Resume Bullet Points

Choose the points that best fit your resume layout.

## Project: High-Performance C++ Key-Value Cache
*Technologies: C++20, Linux, Epoll, TCP/IP, Docker, Google Benchmark*

### Option 1: Performance Focused
*   Designed and implemented a high-throughput Key-Value store in **C++20**, utilizing **Epoll** for non-blocking I/O to handle concurrent connections.
*   Optimized concurrency by migrating from a global mutex to a **Sharded LRU** architecture, reducing lock contention and achieving an **8.4x performance speedup** in multi-threaded benchmarks.
*   Engineered a custom **Binary Protocol** (Header+Body) to minimize network overhead and parsing latency compared to text-based protocols.
*   Implemented **AOF (Append-Only File)** persistence mechanism to ensure data durability and crash recovery.

### Option 2: Systems Engineering Focused
*   Built a thread-safe **LRU Cache** from scratch using `std::list` and `std::unordered_map` with O(1) time complexity for operations.
*   Developed a **TCP Server** using the Reactor pattern and **Epoll** edge-triggering for efficient event handling on Linux.
*   Integrated **Google Benchmark** and **GTest** for rigorous performance profiling and unit testing.
*   Containerized the application using **Docker** (multi-stage build) and set up **GitHub Actions** for automated CI/CD pipelines.

### Option 3: Concise / One-Liner
*   **C++ KV Cache**: Built a high-performance, sharded Key-Value store with custom binary protocol and AOF persistence; achieved 8.4x concurrency speedup via lock striping.

## Key Skills Demonstrated
*   **C++**: RAII, Smart Pointers, Templates, Move Semantics, STL.
*   **Concurrency**: Mutex, Lock Granularity, Thread Pools, Race Condition handling.
*   **Systems**: Socket Programming, File I/O, Memory Management.
*   **Tools**: CMake/Xmake, Docker, Git, GDB, Valgrind.
