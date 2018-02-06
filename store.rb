module Redux
  def self.create_store(reducer)
    Store.new(reducer)
  end

  def self.combine_reducers(reducers)
    -> (state, action) {
      state ||= {}

      reducers.reduce({}) { |next_state, (key, reducer)|
        next_state[key] = reducer.call(state[key], action)
        next_state
      }
    }
  end

  class Store
    def initialize(reducer)
      @reducer = reducer
      @state = nil
      @listeners = []
      dispatch({})
    end

    def dispatch(action)
      @state = @reducer.call(@state, action)
      @listeners.each { |l| l.call(@state) }
    end

    def subscribe(listener)
      @listeners.push(listener)
      ->{ @listeners.delete(listener) }
    end
  end
end

counter_reducer = -> (state, action) {
  state ||= 0

  case action[:type]
  when 'increment'
    state += 1
  when 'decrement'
    state -= 1
  else
    state
  end
}

counter_listener = -> (state) { puts "Counter: #{state[:counter]}" }

root_reducer = Redux.combine_reducers({ counter: counter_reducer })

store = Redux.create_store(root_reducer)
delete_counter_listener = store.subscribe(counter_listener)

store.dispatch({ type: 'increment' })
store.dispatch({ type: 'increment' })
store.dispatch({ type: 'increment' })

delete_counter_listener.call

store.dispatch({ type: 'decrement' })
