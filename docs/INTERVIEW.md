# Interview Preparation Guide

## Project Overview
**High-Performance C++ Key-Value Cache**
A thread-safe, persistent key-value store supporting custom binary protocol, LRU eviction, and high concurrency.

## Core Design Decisions

### 1. Why C++20?
- **Performance**: Zero-overhead abstractions and manual memory management control.
- **Modern Features**: Used `std::unique_ptr` for ownership management (RAII), `std::optional` for clean API returns, and `std::thread` for concurrency.
- **Concepts**: (If used) Enforced type constraints on templates.

### 2. Concurrency Model
- **Evolution**: Started with a single `std::mutex` protecting the `LRUCache`.
- **Bottleneck**: Profiling showed high contention on the single mutex under high load.
- **Solution**: Implemented **Sharded Locking**.
  - Keys are hashed to one of $N$ shards (default 16).
  - Each shard has its own mutex and LRU list.
  - Reduces lock granularity, allowing parallel access to different shards.
  - **Result**: 8.4x speedup on 16 threads.

### 3. Network Architecture
- **Model**: Reactor Pattern using `epoll` (Edge Triggered).
- **Why Epoll?**: Handles thousands of concurrent connections efficiently compared to thread-per-connection.
- **Non-blocking I/O**: Ensures the main loop never blocks waiting for data.

### 4. Persistence (AOF)
- **Mechanism**: Append-Only File. Every write (`SET`, `DEL`) is appended to a log file.
- **Recovery**: On startup, the server reads the AOF and replays commands to rebuild the memory state.
- **Trade-off**: Faster writes (sequential I/O) vs slower recovery (replay time).

## Common Interview Questions

### Q: How does your LRU implementation work?
**A:** It uses a combination of a `std::list` (doubly linked list) and a `std::unordered_map`.
- **Map**: Stores `Key -> List Iterator`. Allows O(1) access.
- **List**: Stores `{Key, Value}` pairs ordered by usage.
- **Get**: Look up in map, move node to front of list.
- **Put**: Look up. If exists, update and move to front. If new, insert at front. If full, remove back (least recently used) and remove from map.

### Q: Why did you choose a Binary Protocol over JSON/HTTP?
**A:**
- **Efficiency**: Smaller payload size (no field names, compact integers).
- **Parsing Speed**: Fixed-size header allows direct casting/reading, avoiding expensive string parsing.
- **Structure**:
  - `Magic` (2 bytes): Sanity check.
  - `Version` (1 byte): Future proofing.
  - `Command` (1 byte): Operation type.
  - `KeyLen/ValueLen` (4 bytes): Explicit lengths for safe reading.

### Q: How would you handle "Hot Keys" in a sharded design?
**A:**
- **Problem**: If one key is accessed 90% of the time, that specific shard's lock becomes a bottleneck, negating the benefit of sharding.
- **Solutions**:
  1.  **Local Cache**: Client-side caching.
  2.  **Read-Only Replicas**: If it's read-heavy, replicate the hot key across multiple shards or nodes.

### Q: How do you ensure data consistency with AOF?
**A:**
- Currently, I flush to disk periodically. In a production system, I would use `fsync` strategies (Always, EverySec, No) to balance safety vs performance.
- **Crash Recovery**: The AOF is a log of truth. Replaying it restores the last consistent state.

### Q: What was the hardest bug you faced?
**A:** (Example)
- **Scenario**: Deadlocks or race conditions during the transition to Sharded LRU.
- **Fix**: Ensuring that operations strictly lock only the required shard and never hold multiple shard locks simultaneously (or acquire them in a deterministic order if needed).

## Performance Data (Memorize These)
- **Single Thread**: ~34ns latency.
- **16 Threads (Global Lock)**: ~5369ns (High contention).
- **16 Threads (Sharded)**: ~635ns.
- **Improvement**: ~8.4x speedup.
