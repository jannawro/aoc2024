import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject, Normal}
import gleam/otp/actor.{type Next, Stop}

type Msg(key, value) {
  Shutdown
  Get(key: key, client: Subject(Result(value, Nil)))
  Set(key: key, value: value)
}

type CacheServer(key, value) =
  Subject(Msg(key, value))

fn msg_handler(
  message: Msg(key, value),
  map: Dict(key, value),
) -> Next(Msg(key, value), Dict(key, value)) {
  case message {
    Shutdown -> Stop(Normal)
    Get(key, client) -> {
      process.send(client, dict.get(map, key))

      actor.continue(map)
    }
    Set(key, value) -> actor.continue(dict.insert(map, key, value))
  }
}

pub opaque type Cache(key, value) {
  Cache(server: CacheServer(key, value))
}

pub fn create(fun: fn(Cache(key, value)) -> t) -> t {
  let assert Ok(server) = actor.start(dict.new(), msg_handler)
  let result = fun(Cache(server))
  process.send(server, Shutdown)
  result
}

pub fn set(cache: Cache(key, value), key: key, value: value) -> Nil {
  process.send(cache.server, Set(key, value))
}

pub fn get(cache: Cache(key, value), key: key) -> Result(value, Nil) {
  process.call(cache.server, Get(key, _), 1000)
}

pub fn memoize(cache: Cache(key, value), key: key, fun: fn() -> value) -> value {
  let result = case get(cache, key) {
    Ok(value) -> value
    Error(Nil) -> fun()
  }
  set(cache, key, result)
  result
}
