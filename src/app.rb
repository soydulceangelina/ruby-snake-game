# typed: true
require_relative "view/ruby2d"
require_relative "model/state"
require_relative "actions/actions"
require 'sorbet-runtime'

class App
    extend T::Sig

    def initialize
        @state = T.let(Model::initial_state, Model::State)
    end

    def start
        @view = View::Ruby2dView.new(self)
        timer_thread = Thread.new { init_timer(@view) }
        @view.start(@state)
        timer_thread.join
    end

    def init_timer(view)
        loop do
            if @state.game_finished
                puts "Game over"
                puts "score: #{@state.snake.positions.length}"
                break
            end
            @state = Actions::move_snake(@state)
            @view.renderGame(@state)
            sleep 0.5
        end
    end

    def send_action(action, params)
        new_state = Actions.send(action, @state, params)
        if new_state.hash != @state.hash
            @state = new_state
            @view.renderGame(@state)
        end
    end
end

app = App.new
app.start