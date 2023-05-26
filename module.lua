local system = {}
local cache = {}
local handlerFunction = script:WaitForChild("CacheHandler")
local events = {
	onAdded = Instance.new("BindableEvent");
	onRemoved = Instance.new("BindableEvent")
}
local runService = game:GetService("RunService")

export type SavedCache = {
	data: any|nil;
	expire:number;
	onClear:RBXScriptSignal;
	Again:(key:string,value:any,expire:number)->(SavedCache);
}

export type ThreadObject = {
	thread:thread;
	Close: () -> ();
	onClose: RBXScriptSignal;
	onStart: RBXScriptSignal;
}

export type ClearedCacheObject = {
	clearedCache: {};
	onClear: RBXScriptSignal;
}

export type DefaultTable = {
	key:string|number|nil;
	value:string|number|boolean|{}|nil
}

function system:Get(key:string):{}?
	return cache[key] or nil
end

function system:Set(key:string,value:any,expire:number):SavedCache
	local eventsM = {
		onClear = Instance.new("BindableEvent")
	}
	cache[key] = value
	events.onAdded:Fire({key=key,value=value})
	task.delay(expire,function()
		eventsM.onClear:Fire(cache[key])
		cache[key] = nil
		events.onRemoved:Fire({key=key,value=value})
	end)
	return {
		data = cache[key];
		expire = expire;
		onClear = eventsM.onClear.Event;
		Again = function(key:string,value:any,expire:number):SavedCache
			local em = system:Set(key,value,expire)
			return em
		end
	}
end

local IsServer,IsClient = runService:IsServer(), runService:IsClient()

if IsServer then
	handlerFunction.OnServerInvoke = function(plr,key:string?)
		if key then
			return cache[key] or nil
		else
			return cache
		end
	end
end

if IsClient then
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
	if limit <= 1e3 then
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
		warn('[QuickCache]: Limit value must be lower or equals to 1,000!')
		return {}
	end
end

function system.thread(a:()->(),expire:number?) : ThreadObject
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
		thread = threadC;
		Close = function()
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
		onStart = startevent.Event;
	}
end

function system:ClearAllCache() : ClearedCacheObject
	local clearedCache = cache
	local onClearEvent = Instance.new("BindableEvent")
	cache = {}
	events.onRemoved:Fire({value=clearedCache})
	task.delay(task.wait(),function()
		onClearEvent:Fire(clearedCache)
	end)
	return {
		clearedCache = clearedCache,
		onClear = onClearEvent.Event
	}
end

function system:ClearAllCacheWithin(key:string)
	if (cache[key] and typeof(cache[key]) == "table") then
		local oldCache = cache[key]
		cache[key] = {}
		events.onRemoved:Fire({key=key; value=oldCache})
	else
		warn(`[QuickCache]: Key {key} not found.`)
		return false
	end
end

system.onCacheAdded = events.onAdded.Event
system.onCacheRemoved = events.onRemoved.Event

return system
