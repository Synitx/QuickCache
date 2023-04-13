<h1>Quick Cache v1.0</h1>
<p>Store cache with ease!</p>

[spoiler]`(Hey guys, so ive made this simple cache module, cuz i was bored so heres the documentation for it)`[/spoiler]

QuickCache is a module that provides a simple and easy-to-use cache system for Lua programs running on the Roblox game platform. This module allows users to store data in a cache with an expiration time, get and set values in the cache, get cache data in ascending or descending order, and clear the cache. The module also supports thread management and provides event handlers to track cache clearing and thread completion.

___

### Installation

To use the QuickCache module, follow these steps:

1. Get the place file or module link from below.
2. Require the module in your server/client script.
3. Then store/get your cached data!

___

> ## Quick short tutorial (By Chat-GPT)

This is a Lua code that implements a cache system with different functionalities. The cache is stored in the `cache` variable which is a Lua table. The cache can be accessed using the `Get` function, which takes a `key` as an argument and returns the corresponding value stored in the cache. If the `key` is not found in the cache, it returns `nil`. The `Set` function is used to add or update a value in the cache. It takes three arguments: `key`, `value`, and `expire`. `key` is the identifier of the value in the cache, `value` is the actual value to be stored, and `expire` is the time in seconds after which the value will be automatically removed from the cache.

The code also defines two functions `GetServerCache` and `GetClientCache`, which are used to access the cache from the server and client, respectively. These functions use the `CacheHandler` script to communicate between the server and client. The `GetCacheInOrder` function is used to sort the cache based on the specified value and order (ascending or descending).

The `thread` function is used to run a function in a separate thread, which can be canceled after a specified time using the `Close` method. The `ClearAllCache` function is used to clear the entire cache and returns an event that fires when the cache is cleared.

Overall, this Lua code implements a flexible cache system with various functionalities that can be used in Lua scripts in Roblox or other Lua environments.

___

### Usage

First, require the module at the beginning of your script:

```
local QuickCache = require(game:GetService("ReplicatedStorage"):WaitForChild("QuickCache"))
```

Once you have required the module, you can call its functions and methods as follows:

### `QuickCache:Get(key:string)`

Retrieves a value from the cache with the given key. If the key is not found in the cache, returns `nil`.

* `key` (string): The key to retrieve from the cache.

Returns:

* If a value is found in the cache with the given key, returns the value.
* If no value is found in the cache with the given key, returns `nil`.

```
-- Set a key-value pair in the cache
myCache:Set("myKey", "myValue", 60)

-- Get the value of a key in the cache
local value = myCache:Get("myKey")
print(value) -- "myValue"
```

___

### `QuickCache:Set(key:string,value:any,expire:number)`

Sets a value in the cache with the given key and an expiration time. If the key already exists in the cache, the value will be overwritten. When the expiration time has passed, the value will be removed from the cache.

* `key` (string): The key to set in the cache.
* `value` (any): The value to set in the cache.
* `expire` (number): The time in seconds until the value should expire.

Returns:

* If the value was successfully set in the cache, returns a table with the following properties:
  * `data` (any): The value that was set in the cache.
  * `expire` (number): The expiration time for the value.
  * `onClear` (RBXScriptSignal): A bindable event that fires when the value is cleared from the cache.

```
-- Set a key-value pair in the cache with a 60-second expiration time
local cachedData = myCache:Set("myKey", "myValue", 60)

-- Access the cached data and expiration time
print(cachedData.data) -- "myValue"
print(cachedData.expire) -- 60

-- Wait for the onClear event to fire
cachedData.onClear:Wait()
print(myCache:Get("myKey")) -- nil
```

___

### `QuickCache:GetServerCache(key:string?)`

Retrieves the cache on the server. If a `key` is provided, retrieves the value with the given key from the cache. If no `key` is provided, retrieves the entire cache.

* `key` (string): The key to retrieve from the cache (optional).

Returns:

* If a `key` is provided and a value is found in the cache with the given key, returns the value.
* If a `key` is provided and no value is found in the cache with the given key, returns `nil`.
* If no `key` is provided, returns the entire cache.

```
-- Get the cache data for a key on the server
local serverData = myCache:GetServerCache("myKey")
print(serverData) -- "myValue"
```

___

### `QuickCache:GetClientCache(client:Player,key:string?)`

Retrieves the cache on the client. If a `key` is provided, retrieves the value with the given key from the cache. If no `key` is provided, retrieves the entire cache.

* `client` (Player): The client to retrieve the cache from.
* `key` (string): The key to retrieve from the cache (optional).

Returns:

* If a `key` is provided and a value is found in the cache with the given key, returns the value.
* If a `key` is provided and no value is found in the cache with the given key,

```
local clientData = myCache:GetClientCache(player, "myKey")
print(clientData) -- "myValue"
```
___

### `QuickCache:GetCacheInOrder(value: any, descending: boolean, limit: number, parameter: string)`

Retrieves a table of cached values in a specified order.

* `value`: The value to sort the cached values by.
* `descending`: A boolean indicating whether to sort the cached values in descending order (i.e., highest to lowest) or ascending order (i.e., lowest to highest).
* `limit`: The maximum number of cached values to return.
* `parameter`: An optional string representing a property to sort the cached values by.
* Returns: A table of cached values, sorted in the specified order.

```
myCache:Set("key", {{name = "Charlie", age = 20},{name = "Bob", age = 30},{name = "Alice", age = 25}}, 60)

-- Get the cache data in descending order by age
local data = myCache:GetCacheInOrder("key", true, 2, "age")

-- Print the cached data
for i, v in ipairs(data) do
    print(`{v.name}, {v.age}`)
end

--[[
Expected output:
Bob, 30
Alice, 25
Charlie, 20
--]]
```
___

### `QuickCache:ClearAllCache()`

Clears all cached values in the cache.

* Returns: A table containing the cleared cache, and a `BindableEvent` that fires when the cache is cleared with old cache as returned parameter.

```
-- Set some values in the cache
QuickCache:Set("key1", "value1", 60)
QuickCache:Set("key2", "value2", 60)
QuickCache:Set("key3", "value3", 60)

-- Clear the cache
local response = QuickCache:ClearAllCache()
response.onClear:Wait()  -- Wait for the cache to be cleared

-- Attempt to retrieve a value from the cache
local value = QuickCache:Get("key1")
print(value)  -- Output: nil
```
___

### `QuickCache.thread(func: () -> (), expire: number?)`

Executes the specified function in a separate thread.

* `func`: A function to execute in a separate thread.
* `expire`: An optional time, in seconds, after which to automatically close the thread.
* Returns: A table containing the thread, a `Close()` function to manually close the thread, and `BindableEvents` that fire when the thread starts and ends.

```
-- Define a function that takes some time to run
local function func()
    local sum = 0
    for i = 1, 10000000 do
        sum = sum + i
    end
    print("Finished slowFunction: " .. sum)
end

-- Start the slow function in a new thread and wait for it to finish
local threadInfo = QuickCache.thread(func)
threadInfo.onStart:Wait() -- Wait for the thread to start
print("Started func in a new thread")
threadInfo.onClose:Wait() -- Wait for the thread to finish
print("Finished/Closed func in a new thread")
-- OR ---
threadInfo:Close() -- Closes the thread without waiting
```
___

> ### Why use this module?

The QuickCache module can be useful in situations where you need to store and retrieve data quickly and efficiently. Here are some reasons why you might consider using it:

1. Improved performance: QuickCache can help improve performance by reducing the amount of time it takes to access and retrieve data. By storing data in memory instead of repeatedly fetching it from a database or other external source, you can reduce latency and improve overall application performance.
2. Simplicity: QuickCache provides a simple and intuitive API for caching and retrieving data, which can save you time and effort when developing applications.
3. Flexibility: QuickCache supports both server and client-side caching, so you can use it in a wide range of applications and scenarios. Additionally, it allows you to set expiration times on cached data, which can help you manage memory usage and prevent your cache from becoming too large.

Overall, the QuickCache module can be a useful tool for developers looking to improve application performance and simplify the caching process.

___

<div align="center"><a href="https://www.roblox.com/library/13115701183/QuickCache">Roblox Model</a><br> 
