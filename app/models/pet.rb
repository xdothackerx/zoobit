class Pet < ActiveRecord::Base
  belongs_to :user
  has_one :pet_hunger, dependent: :destroy
  has_one :pet_tiredness, dependent: :destroy
  has_one :pet_boredom, dependent: :destroy
  validates :name, presence: true
  validates :type, presence: true, inclusion: { in: %w(Dog Cat Bird Rabbit),
    message: "%{value} is not an available type of pet." }
  validates :gender, presence: true, inclusion: { in: %w(Female Male)}
  before_create :initialize_pet

  scope :dogs, -> {where(type: "Dog")}
  scope :cats, -> {where(type: "Cat")}
  scope :birds, -> {where(type: "Bird")}
  scope :rabbits, -> {where(type: "Rabbit")}

  def update_happiness(current_time)
    self.pet_hunger.increase(current_time)
    self.pet_tiredness.increase(current_time)
    self.pet_boredom.increase(current_time)
    self.calculate_happiness
  end

  def calculate_happiness
    self.happiness = ((100 - self.pet_hunger.value)/2 + (100 - self.pet_boredom.value)/2)
    self.happiness = 100 if self.happiness > 100
    happy_value = self.happiness < 40 ? "sad" : "happy"
    self.img_loc = "#{self.type.downcase}_#{happy_value}.svg"
    self.body_img = "#{self.type.downcase}.svg"
  end

private
  def initialize_pet
    self.happiness = 100
    self.img_loc = "#{self.type.downcase}_happy.svg"
    self.pet_hunger = PetHunger.new(pet_id: self.id)
    self.pet_tiredness = PetTiredness.new(pet_id: self.id)
    self.pet_boredom = PetBoredom.new(pet_id: self.id)
  end
end
