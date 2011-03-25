require 'spec_helper'

describe 'CartoDB client' do

  it "should create a table and get its table definition" do
    table = @cartodb.create_table 'cartodb_spec', [
                                    {:name => 'field1', :type => 'text'},
                                    {:name => 'field2', :type => 'number'},
                                    {:name => 'field3', :type => 'date'},
                                    {:name => 'field4', :type => 'boolean'}
                                  ]

    table.should_not be_nil
    table[:id].should be > 0
    table = @cartodb.table 'cartodb_spec'
    table.schema.should have(11).items
    table.schema.should include(["cartodb_id", "number"])
    table.schema.should include(["name", "string"])
    table.schema.should include(["latitude", "number", "latitude"])
    table.schema.should include(["longitude", "number", "longitude"])
    table.schema.should include(["description", "string"])
    table.schema.should include(["created_at", "date"])
    table.schema.should include(["updated_at", "date"])
    table.schema.should include(["field1", "string"])
    table.schema.should include(["field2", "number"])
    table.schema.should include(["field3", "date"])
    table.schema.should include(["field4", "boolean"])
  end

  it "should add and remove colums in a previously created table" do
    @cartodb.create_table 'cartodb_spec'
    @cartodb.add_column 'cartodb_spec', 'field1', 'text'
    @cartodb.add_column 'cartodb_spec', 'field2', 'number'
    @cartodb.add_column 'cartodb_spec', 'field3', 'date'

    table = @cartodb.table 'cartodb_spec'
    table.schema.should have(10).items
    table.schema.should include(["field1", "string"])
    table.schema.should include(["field2", "number"])
    table.schema.should include(["field3", "date"])

    @cartodb.drop_column 'cartodb_spec', 'field3'
    table = @cartodb.table 'cartodb_spec'
    table.schema.should have(9).items
    table.schema.should_not include(["field3", "date"])
  end

  it "should change a previously created column" do
    @cartodb.create_table 'cartodb_spec', [{:name => 'field1', :type => 'text'}]
    @cartodb.change_column 'cartodb_spec', "field1", "changed_field", "number"
    table = @cartodb.table 'cartodb_spec'
    table.schema.should_not include(["field1", "string"])
    table.schema.should include(["changed_field", "number"])
  end

  it "should return user's table list" do
    table_1 = @cartodb.create_table 'table #1'
    table_2 = @cartodb.create_table 'table #2'

    tables_list = @cartodb.tables
    tables_list.should have(2).items
    tables_list.map(&:id).should include(table_1[:id])
    tables_list.map(&:id).should include(table_2[:id])
  end

  it "should drop a table" do
    table_1 = @cartodb.create_table 'table #1'
    table_2 = @cartodb.create_table 'table #2'
    table_3 = @cartodb.create_table 'table #3'

    @cartodb.drop_table 'table_2'

    tables_list = @cartodb.tables
    tables_list.should have(2).items
    tables_list.map(&:id).should include(table_1[:id])
    tables_list.map(&:id).should include(table_3[:id])
  end

  it "should insert a row in a table" do
    table = @cartodb.create_table 'table #1', [
                                    {:name => 'field1', :type => 'text'},
                                    {:name => 'field2', :type => 'number'},
                                    {:name => 'field3', :type => 'date'},
                                    {:name => 'field4', :type => 'boolean'}
                                  ]

    today = Time.now

    inserted_row = @cartodb.insert_row 'table_1', {
      'name'        => 'cartoset',
      'description' => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
      'latitude'    => 40.423012,
      'longitude'   => -3.699732,
      'field1'      => 'lorem',
      'field2'      => 100.99,
      'field3'      => today,
      'field4'      => true
    }

    record = @cartodb.row 'table_1', inserted_row.id

    record.name.should == 'cartoset'
    record.latitude.should == 40.423012
    record.longitude.should == -3.699732
    record.description.should == 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
    record.field1.should == 'lorem'
    record.field2.should == 100.99
    record.field3.should == today.strftime("%Y-%m-%d %H:%M:%S")
    record.field4.should == true
  end

  it "should update a row in a table" do
    table = @cartodb.create_table 'table #1', [
                                    {:name => 'field1', :type => 'text'},
                                    {:name => 'field2', :type => 'number'},
                                    {:name => 'field3', :type => 'date'},
                                    {:name => 'field4', :type => 'boolean'}
                                  ]

    today = Time.now

    record = @cartodb.insert_row 'table_1', {
      'name'        => 'cartoset',
      'description' => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
      'latitude'    => 40.423012,
      'longitude'   => -3.699732,
      'field1'      => 'lorem',
      'field2'      => 100.99,
      'field3'      => today,
      'field4'      => true
    }

    @cartodb.update_row 'table_1', record.id, {
      'name'        => 'updated_row',
      'description' => 'Eu capto illum, iustum, brevitas, lobortis torqueo importunus, capio sudo. Genitus importunus amet iaceo, abluo obruo consequat, virtus eros, aliquip iustum nisl duis zelus. Ymo augue nobis exerci letatio sed.',
      'latitude'    => 40.415113,
      'longitude'   => -3.699871,
      'field1'      => 'illum',
      'field2'      => -83.24,
      'field3'      => today + 84600,
      'field4'      => false
    }

    record = @cartodb.row 'table_1', record.id

    record.name.should        == 'updated_row'
    record.latitude.should    == 40.415113
    record.longitude.should   == -3.699871
    record.description.should == 'Eu capto illum, iustum, brevitas, lobortis torqueo importunus, capio sudo. Genitus importunus amet iaceo, abluo obruo consequat, virtus eros, aliquip iustum nisl duis zelus. Ymo augue nobis exerci letatio sed.'
    record.field1.should      == 'illum'
    record.field2.should      == -83.24
    record.field3.should      == (today + 84600).strftime("%Y-%m-%d %H:%M:%S")
    record.field4.should      == false
  end

  it "should delete a table's row" do
    table = @cartodb.create_table 'table #1', [
                                    {:name => 'field1', :type => 'text'},
                                    {:name => 'field2', :type => 'number'},
                                    {:name => 'field3', :type => 'date'},
                                    {:name => 'field4', :type => 'boolean'}
                                  ]

    today = Time.now

    record = @cartodb.insert_row 'table_1', {
      'name'        => 'cartoset',
      'description' => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
      'latitude'    => 40.423012,
      'longitude'   => -3.699732,
      'field1'      => 'lorem',
      'field2'      => 100.99,
      'field3'      => today,
      'field4'      => true
    }

    @cartodb.delete_row 'table_1', record.id

    records = @cartodb.records 'table_1'

    records.name.should be == 'table_1'
    records.total_rows.should == 0
    records.rows.should be_empty
  end

  it "should execute a select query and return results" do
    table = @cartodb.create_table 'table #1'

    50.times do
      @cartodb.insert_row 'table_1', {
        'name'        => String.random(15),
        'description' => String.random(200),
        'latitude'    => rand(90),
        'longitude'   => rand(180)
      }
    end

    results = @cartodb.query("SELECT * FROM table_1")
    results.should_not be_nil
    results.time.should be > 0
    results.total_rows.should == 50
    results.rows.should have(50).items
    random_row = results.rows.sample
    random_row.cartodb_id.should be > 0
    random_row.name.should_not be_empty
    random_row.latitude.should be > 0
    random_row.longitude.should be > 0
    random_row.description.should_not be_empty
    random_row.created_at.should_not be_nil
    random_row.updated_at.should_not be_nil
  end

  it "should get a table by its name" do
    created_table = @cartodb.create_table 'table_with_name'

    table = @cartodb.table 'table_with_name'
    table.should_not be_nil
    table[:id].should be == created_table[:id]
  end

  it "should return nil when requesting a table which does not exists" do
    expect{@cartodb.table('non_existing_table')}.to raise_error(CartoDB::Client::Error, /404 - Not found/)
  end
end
