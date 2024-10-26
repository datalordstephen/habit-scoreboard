import Buffer "mo:base/Buffer";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Time "mo:base/Time";

actor {
  type HabitId = Nat;
  
  private type HabitEntryStore = {
    date: Time.Time;
    completed: Bool;
    points: Nat;
  };

  private type HabitStore = {
    id: HabitId;
    name: Text;
    description: Text;
    pointsPerCompletion: Nat;
    streak: Nat;
    entries: Buffer.Buffer<HabitEntryStore>;
  };

  public type HabitEntry = {
    date: Time.Time;
    completed: Bool;
    points: Nat;
  };

  public type Habit = {
    id: HabitId;
    name: Text;
    description: Text;
    pointsPerCompletion: Nat;
    streak: Nat;
    entries: [HabitEntry];
  };

  var habits = Buffer.Buffer<HabitStore>(0);

  public func createHabit(name: Text, description: Text, pointsPerCompletion: Nat) : async HabitId {
    let habitId = habits.size();
    let newHabit: HabitStore = {
      id = habitId;
      name = name;
      description = description;
      pointsPerCompletion = pointsPerCompletion;
      streak = 0;
      entries = Buffer.Buffer<HabitEntryStore>(0);
    };
    habits.add(newHabit);
    habitId
  };

  public func logHabitCompletion(habitId: HabitId, completed: Bool) : async Bool {
    if (habitId >= habits.size()) return false;
    let habit = habits.get(habitId);
    
    let points = if (completed) habit.pointsPerCompletion else 0;
    let newStreak = if (completed) habit.streak + 1 else 0;
    
    let entry: HabitEntryStore = {
      date = Time.now();
      completed = completed;
      points = points;
    };
    
    let updatedHabit: HabitStore = {
      id = habit.id;
      name = habit.name;
      description = habit.description;
      pointsPerCompletion = habit.pointsPerCompletion;
      streak = newStreak;
      entries = habit.entries;
    };
    updatedHabit.entries.add(entry);
    habits.put(habitId, updatedHabit);
    true
  };

  public query func getHabit(id: HabitId) : async ?Habit {
    if (id >= habits.size()) return null;
    let habit = habits.get(id);
    
    let entriesArray = Buffer.Buffer<HabitEntry>(0);
    for (entry in habit.entries.vals()) {
      entriesArray.add({
        date = entry.date;
        completed = entry.completed;
        points = entry.points;
      });
    };

    ?{
      id = habit.id;
      name = habit.name;
      description = habit.description;
      pointsPerCompletion = habit.pointsPerCompletion;
      streak = habit.streak;
      entries = Buffer.toArray(entriesArray);
    }
  };

  public query func getAllHabits() : async [{
    id: HabitId;
    name: Text;
    description: Text;
    pointsPerCompletion: Nat;
    streak: Nat;
    totalPoints: Nat;
  }] {
    let results = Buffer.Buffer<{
      id: HabitId;
      name: Text;
      description: Text;
      pointsPerCompletion: Nat;
      streak: Nat;
      totalPoints: Nat;
    }>(0);

    for (habit in habits.vals()) {
      var totalPoints = 0;
      for (entry in habit.entries.vals()) {
        totalPoints += entry.points;
      };

      results.add({
        id = habit.id;
        name = habit.name;
        description = habit.description;
        pointsPerCompletion = habit.pointsPerCompletion;
        streak = habit.streak;
        totalPoints = totalPoints;
      });
    };
    Buffer.toArray(results)
  };
}