MCDebuggingTools
================

Collection of debuging tools that can be added to your project

##MCMemoryWarrningGenerator
Extremely simple to use tool to simulate low memory conditions in your application so you can ensure that it behaves correctly when receiving memory warnings

PERFORM_MEMORY_WARNING_AT_INTERVAL(NSTimeInterval interval)
generates a simulated memory warning continuously at the specified interval in seconds

ALLOCATE_MEMORY_BLOCK_AT_INTERNAL(NSTimeInterval interval)
Allocates memory continuously at the specified interval in seconds
