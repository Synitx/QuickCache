local system = {}
local cache = {}
local handlerFunction = script:WaitForChild("CacheHandler")

function system:Get(key:string):{}?
	return cache[key] or nil
end

function system:Set(key:string,value:any,expire:number):{}?
	local events = {
		onClear = Instance.new("BindableEvent")
	}
	cache[key] = value
	task.delay(expire,function()
		events.onClear:Fire(cache[key])
		cache[key] = nil
	end)
	return {
		data = cache[key];
		expire = expire;
		onClear = events.onClear.Event;
	} or nil
end

if game:GetService("RunService"):IsServer() then
	handlerFunction.OnServerInvoke = function(plr,key:string?)
		if key then
			return cache[key] or nil
		else
			return cache
		end
	end
end

if game:GetService("RunService"):IsClient() then
	handlerFunction.OnClientInvoke = function(key:string?)
		if key then
			return cache[key] or nil
		else
			return cache
		end
	end
end

function system:GetServerCache(key:string?)
	if game:GetService("RunService"):IsClient() then
		local response = handlerFunction:InvokeServer(key)
		return response or nil
	else
		warn("[QuickCache]: GetServerCache can only be called from client")
		return {}
	end
end

function system:GetClientCache(client:Player,key:string?)
	if game:GetService("RunService"):IsServer() then
		local response = handlerFunction:InvokeClient(client,key)
		return response or nil
	else
		warn("[QuickCache]: GetClientCache can only be called from server")
		return {}
	end
end

function system:GetCacheInOrder(value:any,decending:boolean,limit:number,parameter:string?):{}
	local list = cache
	table.sort(list[value],function(a,b)
		if parameter then
			if decending then
				return a[parameter] > b[parameter]
			else
				return a[parameter] < b[parameter]
			end
		else
			if typeof(a) == "table" and typeof(b) ~= "table" then
				if decending then
					return #a > b
				else
					return #a < b
				end
			elseif typeof(b) == "table" and typeof(a) ~= "table" then
				if decending then
					return a > #b
				else
					return a < #b
				end
			elseif typeof(a) and typeof(b) == "table" then
				if decending then
					return #a > #b
				else
					return #a < #b
				end
			else
				if decending then
					return a > b
				else
					return a < b
				end
			end
		end
	end)
	local output = {}
	if limit <= 200 then
		local index = 0
		for i,v in ipairs(list[value]) do
			if index == limit then
				break
			end
			index+=1
			output[i] = v
		end
		return output or {}
	else
		warn('[QuickCache]: Limit value must be lower or equals to 200!')
		return {}
	end
end

function system.thread(a:()->(),expire:number?)
	local startedAt = os.time()
	local endevent = Instance.new("BindableEvent")
	local startevent = Instance.new("BindableEvent")
	local threadC = coroutine.create(a)
	coroutine.resume(threadC)
	if expire then
		task.delay(expire,function()
			coroutine.close(threadC)
			local endedAt = os.time()
			local expireTime = math.abs(endedAt - startedAt)
			endevent:Fire(startedAt,endedAt,expireTime)
		end)
	end
	task.delay(task.wait(),function()
		startevent:Fire()
		startedAt = os.time()
	end)
	return {
		thread = threadC,
		Close = function(self)
			if threadC then
				coroutine.close(threadC)
				local endedAt = os.time()
				local expireTime = math.abs(endedAt - startedAt)
				endevent:Fire(startedAt,endedAt,expireTime)
				return true
			else
				return false
			end
		end;
		onClose = endevent.Event;
		onStart = startevent.Event
	}
end

function system:ClearAllCache()
	local clearedCache = cache
	local onClearEvent = Instance.new("BindableEvent")
	cache = {}
	task.delay(task.wait(),function()
		onClearEvent:Fire(clearedCache)
	end)
	return {
		clearedCache = clearedCache,
		onClear = onClearEvent.Event
	}
end


return system
