require 'spec_helper'

describe 'CartoDB model scopes' do
  it "should return all records paginated" do
    create_random_circuits(20)

    circuits = MotoGPCircuit.all

    circuits.should have(20).circuits
    circuits.first.should be_a_kind_of(MotoGPCircuit)
    circuits.first.cartodb_id.should be == 1
    circuits.first.name.should be == 'circuit #1'
    circuits.first.description.should be == 'awesome circuit #1'
    circuits.first.latitude.should be == 25.488840
    circuits.first.longitude.should be == 51.453352
    circuits.first.length.should be == '5380m'
    circuits.first.width.should be == '12m'
    circuits.first.left_corners.should be == 6
    circuits.first.right_corners.should be == 10
    circuits.first.longest_straight.should be == '1068m'
    circuits.first.constructed.should be == "2004-01-01T00:00:00+01:00"
    circuits.first.modified.should be == "2004-01-01T00:00:00+01:00"
  end

  it "should count all records" do
    create_random_circuits(20)

    MotoGPCircuit.count.should be == 20

    create_random_circuit

    MotoGPCircuit.count.should be == 21
  end

  it "should find a record by its id" do
    create_random_circuit

    circuit = MotoGPCircuit.where(:cartodb_id => 1)

    circuit.cartodb_id.should be == 1
    circuit.name.should be == 'circuit #1'
    circuit.description.should be == 'awesome circuit #1'
    circuit.latitude.should be == 25.488840
    circuit.longitude.should be == 51.453352
    circuit.length.should be == '5380m'
    circuit.width.should be == '12m'
    circuit.left_corners.should be == 6
    circuit.right_corners.should be == 10
    circuit.longest_straight.should be == '1068m'
    circuit.constructed.should be == "2004-01-01 00:00:00"
    circuit.modified.should be == "2004-01-01 00:00:00"

    same_circuit = MotoGPCircuit.find(1)

    same_circuit.cartodb_id.should be == 1
    same_circuit.name.should be == 'circuit #1'
    same_circuit.description.should be == 'awesome circuit #1'
    same_circuit.latitude.should be == 25.488840
    same_circuit.longitude.should be == 51.453352
    same_circuit.length.should be == '5380m'
    same_circuit.width.should be == '12m'
    same_circuit.left_corners.should be == 6
    same_circuit.right_corners.should be == 10
    same_circuit.longest_straight.should be == '1068m'
    same_circuit.constructed.should be == "2004-01-01 00:00:00"
    same_circuit.modified.should be == "2004-01-01 00:00:00"
  end

  it "should search records by certain filters" do
    new_circuit(:name => 'Losail circuit',       :left_corners => 6, :right_corners => 10).save
    new_circuit(:name => 'Jerez',                :left_corners => 5, :right_corners => 8).save
    new_circuit(:name => 'Estoril',              :left_corners => 4, :right_corners => 9).save
    new_circuit(:name => 'Lemans',               :left_corners => 4, :right_corners => 9).save
    new_circuit(:name => 'Circuit de Catalunya', :left_corners => 5, :right_corners => 8).save

    circuits = MotoGPCircuit.where(:left_corners => 4).where(:right_corners => 9)

    circuits.should have(2).circuits
    circuits.first.name.should be == 'Estoril'
    circuits.last.name.should be == 'Lemans'
    circuits.all.should have(2).circuits
    circuits.all.first.name.should be == 'Estoril'
    circuits.all.last.name.should be == 'Lemans'

    circuits = MotoGPCircuit.where("left_corners = ?", 4).where("right_corners = ?", 9)

    circuits.should have(2).circuits
    circuits.first.name.should be == 'Estoril'
    circuits.last.name.should be == 'Lemans'
    circuits.all.should have(2).circuits
    circuits.all.first.name.should be == 'Estoril'
    circuits.all.last.name.should be == 'Lemans'
  end
end
