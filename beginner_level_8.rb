class Player
  MAX_HP = 20
  CRIT_HP = 11

  

  def play_turn(warrior)
    @last_hp ||= MAX_HP
    @commited = false
    @warrior = warrior
    check_pivot
    run_for_your_life
    check_rest
    @last_hp = warrior.health
    check_captive
    check_attack
    look_around
  end
  
  def taking_damage
    @last_hp > @warrior.health
  end

  def commit_action(condition, action)
    unless @commited
      if condition.call
        action.call
        @commited = true
      end
    end
  end
  
  def walk
    action = lambda { @warrior.walk! }
    condition = lambda { true }
    commit_action condition, action
  end
  
  def check_attack
    action = lambda { @warrior.attack! }
    condition = lambda { @warrior.feel.enemy? }
    commit_action condition, action
  end
  
  def check_rest
    action = lambda { @warrior.rest! }
    condition = lambda { @warrior.health < MAX_HP && !taking_damage }
    commit_action condition, action
  end
  
  def check_captive
    action = lambda { @warrior.rescue! }
    condition = lambda { @warrior.feel.captive? }
    commit_action condition, action
  end

  def run_for_your_life
    action = lambda { @warrior.walk! :backward }
    condition = lambda { @warrior.health < CRIT_HP && taking_damage }
    commit_action condition, action
  end

  def pivot
    action = lambda { @warrior.pivot! }
    condition = lambda { true }
    commit_action condition, action
  end

  def check_pivot
    if @warrior.feel.stairs? || @warrior.feel.wall?
      if @warrior.feel.stairs? && @stairs
        walk
      elsif @warrior.feel.stairs?
        pivot
      else
        @stairs ||= true
        pivot
      end
    end
  end

  def check_shoot
    action = lambda { @warrior.shoot! }
    condition = lambda { true }
    commit_action condition, action
  end

  def minimap
    # trying to not make it too complex, just to solve lvl 8
    @map = []
    @warrior.look.each do |space|
      case 
      when space.empty?
        @map << :empty
      when space.captive?
        @map << :captive
      when space.stairs?
        @map << :stairs
      when space.enemy?
        @map << :enemy
      when space.wall?
        @map << :wall
      else
        raise 'unknown space'
      end
    end
  end

  def look_around
    # trying to not make it complex, just to solve lvl 8
    minimap
    if @map.include?(:enemy)
      if @map.include?(:captive)
        if @map.index(:enemy) < @map.index(:captive)
          check_shoot
        end
      else
        check_shoot
      end
    end
    walk
  end
    
end