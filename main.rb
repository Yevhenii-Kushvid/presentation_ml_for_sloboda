data = []
File.open('./data/table.csv') do |file|
  file.readline
  for row in file
    data << row.split(',')[1].to_f
  end
end
data.reverse!

# Normalize
min, max = data.minmax
data.map! { |val| (val - min) / (max - min) }

# Split
window_size = 7
questions = []
answers = []

data.size.times do |index|
  break if (index + window_size) > (data.size - 1)
  questions << data[index...(index + window_size)]
  answers << data[index + window_size]
end

# create model

class Neuron

  def initialize(number_of_inputs)
    @number_of_inputs
    @threshold = 0.1
    @delta = 0
    @weights = Array.new(number_of_inputs) { rand() }
    @speed_of_study = 0.1
  end

  def solv(question)
    @inputs = question
    sum = @weights.each.with_index.inject(@threshold) do |sum, (val, index)|
      sum + val * question[index]
    end
    @result = function(sum)
  end

  def study(question, answer)
    @error = -2 * (solv(question) - answer)
    vector_of_study = @error * @speed_of_study * derivatino(@result)

    @threshold += vector_of_study
    @weights.size.times do |index|
      @delta = 0.8 * @delta + vector_of_study * @inputs[index]
      @weights[index] += @delta
    end
  end

  private

  def function(x)
    Math::tanh(x)
  end

  def derivatino(x)
    1 - Math::tanh(x) ** 2
  end
end

neuron = Neuron.new(window_size)

# Print data
require 'nyaplot'
require 'nyaplot_utils'

data_plot = Nyaplot::Plot.new
data_line = data_plot.add :line, (0...(data.size)).to_a, data
data_line.color '#0f0'

data_plot.export_html './plots/data.html'

# Plot before
our_answers = []
for question in questions
  our_answers << neuron.solv(question)
end

before_study = Nyaplot::Plot.new
real_answers = before_study.add :line, (0...(answers.size)).to_a, answers
real_answers.color '#000'
our_answers = before_study.add :line, (0...(our_answers.size)).to_a, our_answers
our_answers.color '#00f'
before_study.export_html './plots/before_study.html'

# Study
questions.size.times do |index|
  neuron.study(questions[index], answers[index])
end

# After before
our_answers = []
for question in questions
  our_answers << neuron.solv(question)
end

after_study = Nyaplot::Plot.new
real_answers = after_study.add :line, (0...(answers.size)).to_a, answers
real_answers.color '#000'
our_answers = after_study.add :line, (0...(our_answers.size)).to_a, our_answers
our_answers.color '#00f'
after_study.export_html './plots/after_study.html'