module Factories
  def new_losail_circuit
    MotoGPCircuit.new new_losail_circuit_attributes
  end

  def new_losail_circuit_attributes
    {
      :name             => 'Losail Circuit',
      :description      => 'The fabulous Losail International Circuit lies on the outskirts of Doha, the capital city of Qatar. Built in little over a year, the track cost $58 million USD and required round-the-clock dedication from almost 1,000 workers in order to get it ready for the inaugural event - the Marlboro Grand Prix of Qatar on the 2nd October 2004.',
      :latitude         => 25.488840,
      :longitude        => 51.453352,
      :length           => '5380m',
      :width            => '12m',
      :left_corners     => 6,
      :right_corners    => 10,
      :longest_straight => '1068m',
      :constructed      => Date.new(2004, 1, 1),
      :modified         => Date.new(2004, 1, 1)
    }
  end
end

RSpec.configure{ include Factories }