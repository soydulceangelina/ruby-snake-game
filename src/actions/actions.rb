# typed: true

require 'sorbet-runtime'

module Actions
    extend T::Sig

    sig {params(state: Model::State).returns(Model::State)}
    def self.move_snake(state)
      next_direction = state.curr_direction
      next_position = calc_next_position(state)
      
      if position_is_food?(state, next_position)
        state = grow_snake_to(state, next_position)
        generate_food(state)
      elsif position_is_valid?(state, next_position)
        move_snake_to(state, next_position)
      else
        end_game(state)
      end
    end

    sig {params(state: Model::State, direction: Symbol).returns(Model::State)}
    def self.change_direction(state, direction)
      if next_direction_is_valid?(state, direction)
        state.curr_direction = direction
      else
        puts "Invalid direction"
      end
      state
    end
  
    private

    sig {params(state: Model::State).returns(Model::State)}
    def self.generate_food(state)
      new_food = Model::Food.new(rand(state.grid.rows), rand(state.grid.cols))
      state.food = new_food
      state
    end
    
    sig {params(state: Model::State, next_position: Model::Coord).returns(T::Boolean)}
    def self.position_is_food?(state, next_position)
      state.food.row == next_position.row && state.food.col == next_position.col
    end

    sig {params(state: Model::State, next_position: Model::Coord).returns(Model::State)}
    def self.grow_snake_to(state, next_position)
      new_positions = [next_position] + state.snake.positions
      state.snake.positions = new_positions
      state
    end
    
    sig {params(state: Model::State).returns(Model::Coord)}
    def self.calc_next_position(state)
      curr_position = state.snake.positions.first
      case state.curr_direction
      when Model::Direction::UP
        return Model::Coord.new(
            curr_position.row - 1, 
            curr_position.col)
      when Model::Direction::RIGHT
        return Model::Coord.new(
            curr_position.row, 
            curr_position.col + 1)
      when Model::Direction::DOWN
        return Model::Coord.new(
            curr_position.row + 1,
            curr_position.col)
      when Model::Direction::LEFT
        return Model::Coord.new(
            curr_position.row, 
            curr_position.col - 1)
      end
    end
  
    sig {params(state: Model::State, position: Model::Coord).returns(T::Boolean)}
    def self.position_is_valid?(state, position)
      is_invalid = ((position.row >= state.grid.rows ||
        position.row < 0) || 
        (position.col >= state.grid.cols ||
        position.col < 0))
      return false if is_invalid
      return !(state.snake.positions.include? position)
    end
  
    sig {params(state: Model::State, next_position: Model::Coord).returns(Model::State)}
    def self.move_snake_to(state, next_position)
      new_positions = [next_position] + state.snake.positions[0...-1]
      state.snake.positions = new_positions
      state
    end
  
    sig {params(state: Model::State).returns(Model::State)}
    def self.end_game(state)
      state.game_finished = true
      state
    end

    sig {params(state: Model::State, direction: Symbol).returns(T::Boolean)}
    def self.next_direction_is_valid?(state, direction)
      case state.curr_direction
      when Model::Direction::UP
        return true if direction != Model::Direction::DOWN
      when Model::Direction::DOWN
        return true if direction != Model::Direction::UP
      when Model::Direction::RIGHT
        return true if direction != Model::Direction::LEFT
      when Model::Direction::LEFT
        return true if direction != Model::Direction::RIGHT
      end

      return false
    end
end