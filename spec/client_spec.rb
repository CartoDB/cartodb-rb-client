# coding: UTF-8
require 'spec_helper'

describe 'CartoDB client' do

  it "should create a table and get its table definition" do
    table = CartoDB::Connection.create_table 'cartodb_spec', [
                                    {:name => 'field1', :type => 'text'},
                                    {:name => 'field2', :type => 'number'},
                                    {:name => 'field3', :type => 'date'},
                                    {:name => 'field4', :type => 'boolean'}
                                  ]

    table.should_not be_nil
    table[:id].should be > 0
    table = CartoDB::Connection.table 'cartodb_spec'
    table.schema.should have(10).items
    table.schema.should include(["cartodb_id", "number"])
    table.schema.should include(["name", "string"])
    table.schema.should include(["the_geom", "geometry", "geometry", "point"])
    table.schema.should include(["description", "string"])
    table.schema.should include(["created_at", "date"])
    table.schema.should include(["updated_at", "date"])
    table.schema.should include(["field1", "string"])
    table.schema.should include(["field2", "number"])
    table.schema.should include(["field3", "date"])
    table.schema.should include(["field4", "boolean"])
  end

  it "should create a table from a csv file" do
    table = CartoDB::Connection.create_table 'whs_sites', File.open("#{File.dirname(__FILE__)}/support/whs_features.csv", 'r')

    table.should_not be_nil
    table[:id].should be > 0
    table = CartoDB::Connection.table 'whs_sites'
    table.schema.should have(23).items

    records = CartoDB::Connection.records 'whs_sites', :rows_per_page => 1000
    records.should_not be_nil
    records.rows.should have(911).whs_sites

    records.rows.first.cartodb_id.should be > 0
    records.rows.first.title.should be == "Late Baroque Towns of the Val di Noto (South-Eastern Sicily)"
    records.rows.first.latitude.should be > 0
    records.rows.first.longitude.should be > 0
    records.rows.first.description.should match /Val di Noto \(English: Vallum of Noto\) is a geographical area of south east Sicily/
    records.rows.first.region.should be == "Provinces of Catania, Ragusa, and Syracuse, Sicily"
    records.rows.first.type.should be == "cultural"
    records.rows.first.endangered_reason.should be_nil
    records.rows.first.edited_region.should be == "Provinces of Catania, Ragusa, and Syracuse, Sicily"
    records.rows.first.endangered_year.should be_nil
    records.rows.first.external_links.should be_empty
    records.rows.first.wikipedia_link.should be == "http://en.wikipedia.org/wiki/Val_di_Noto"
    records.rows.first.comments.should be_nil
    records.rows.first.criteria.should be == "[i],[ii],[iv],[v]"
    records.rows.first.iso_code.should be == "IT"
    records.rows.first.size.should be == 1130000.0
    records.rows.first.name.should be == "Late Baroque Towns of the Val di Noto (South-Eastern Sicily)"
    records.rows.first.country.should be == "Italy"
    records.rows.first.whs_site_id.should be == 1024
    records.rows.first.date_of_inscription.should be == "2002"
    records.rows.first.whs_source_page.should be == "http://whc.unesco.org/en/list/1024"
    records.rows.first.created_at.should_not be_nil
    records.rows.first.updated_at.should_not be_nil

  end

  it "should add and remove colums in a previously created table" do
    CartoDB::Connection.create_table 'cartodb_spec'
    CartoDB::Connection.add_column 'cartodb_spec', 'field1', 'text'
    CartoDB::Connection.add_column 'cartodb_spec', 'field2', 'number'
    CartoDB::Connection.add_column 'cartodb_spec', 'field3', 'date'

    table = CartoDB::Connection.table 'cartodb_spec'
    table.schema.should have(9).items
    table.schema.should include(["field1", "string"])
    table.schema.should include(["field2", "number"])
    table.schema.should include(["field3", "date"])

    CartoDB::Connection.drop_column 'cartodb_spec', 'field3'
    table = CartoDB::Connection.table 'cartodb_spec'
    table.schema.should have(8).items
    table.schema.should_not include(["field3", "date"])
  end

  it "should change a previously created column" do
    CartoDB::Connection.create_table 'cartodb_spec', [{:name => 'field1', :type => 'text'}]
    CartoDB::Connection.change_column 'cartodb_spec', "field1", "changed_field", "number"
    table = CartoDB::Connection.table 'cartodb_spec'
    table.schema.should_not include(["field1", "string"])
    table.schema.should include(["changed_field", "number"])
  end

  it "should return user's table list" do
    table_1 = CartoDB::Connection.create_table 'table #1'
    table_2 = CartoDB::Connection.create_table 'table #2'

    tables_list = CartoDB::Connection.tables
    tables_list.should have(2).items
    tables_list.map(&:id).should include(table_1[:id])
    tables_list.map(&:id).should include(table_2[:id])
  end

  it "should drop a table" do
    table_1 = CartoDB::Connection.create_table 'table #1'
    table_2 = CartoDB::Connection.create_table 'table #2'
    table_3 = CartoDB::Connection.create_table 'table #3'

    CartoDB::Connection.drop_table 'table_2'

    tables_list = CartoDB::Connection.tables
    tables_list.should have(2).items
    tables_list.map(&:id).should include(table_1[:id])
    tables_list.map(&:id).should include(table_3[:id])
  end

  it "should insert a row in a table" do
    table = CartoDB::Connection.create_table 'table #1', [
                                    {:name => 'field1', :type => 'text'},
                                    {:name => 'field2', :type => 'number'},
                                    {:name => 'field3', :type => 'date'},
                                    {:name => 'field4', :type => 'boolean'}
                                  ]

    today = DateTime.now

    inserted_row = CartoDB::Connection.insert_row 'table_1', {
      'name'        => 'cartoset',
      'description' => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
      'the_geom'    => RGeo::GeoJSON.encode(RgeoFactory.point(-3.699732, 40.423012)),
      'field1'      => 'lorem',
      'field2'      => 100.99,
      'field3'      => today,
      'field4'      => true
    }

    record = CartoDB::Connection.row 'table_1', inserted_row.id

    record.name.should == 'cartoset'
    record.latitude.should == 40.423012
    record.longitude.should == -3.699732
    record.description.should == 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
    record.field1.should == 'lorem'
    record.field2.should == 100.99
    record.field3.to_s.should == today.to_s
    record.field4.should == true
  end

  it "should update a row in a table" do
    table = CartoDB::Connection.create_table 'table #1', [
                                    {:name => 'field1', :type => 'text'},
                                    {:name => 'field2', :type => 'number'},
                                    {:name => 'field3', :type => 'date'},
                                    {:name => 'field4', :type => 'boolean'}
                                  ]

    today = DateTime.now

    record = CartoDB::Connection.insert_row 'table_1', {
      'name'        => 'cartoset',
      'description' => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
      'the_geom'    => RGeo::GeoJSON.encode(RgeoFactory.point(-3.699732, 40.423012)),
      'field1'      => 'lorem',
      'field2'      => 100.99,
      'field3'      => today,
      'field4'      => true
    }

    CartoDB::Connection.update_row 'table_1', record.id, {
      'name'        => 'updated_row',
      'description' => 'Eu capto illum, iustum, brevitas, lobortis torqueo importunus, capio sudo. Genitus importunus amet iaceo, abluo obruo consequat, virtus eros, aliquip iustum nisl duis zelus. Ymo augue nobis exerci letatio sed.',
      'the_geom'    => RGeo::GeoJSON.encode(RgeoFactory.point(-3.699871, 40.415113)),
      'field1'      => 'illum',
      'field2'      => -83.24,
      'field3'      => today + 1,
      'field4'      => false
    }

    record = CartoDB::Connection.row 'table_1', record.id

    record.name.should        == 'updated_row'
    record.latitude.should    == 40.415113
    record.longitude.should   == -3.699871
    record.description.should == 'Eu capto illum, iustum, brevitas, lobortis torqueo importunus, capio sudo. Genitus importunus amet iaceo, abluo obruo consequat, virtus eros, aliquip iustum nisl duis zelus. Ymo augue nobis exerci letatio sed.'
    record.field1.should      == 'illum'
    record.field2.should      == -83.24
    record.field3.to_s.should == (today + 1).to_s
    record.field4.should      == false
  end

  it "should delete a table's row" do
    table = CartoDB::Connection.create_table 'table #1', [
                                    {:name => 'field1', :type => 'text'},
                                    {:name => 'field2', :type => 'number'},
                                    {:name => 'field3', :type => 'date'},
                                    {:name => 'field4', :type => 'boolean'}
                                  ]

    today = Time.now

    record = CartoDB::Connection.insert_row 'table_1', {
      'name'        => 'cartoset',
      'description' => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
      'the_geom'    => RGeo::GeoJSON.encode(RgeoFactory.point(-3.699732, 40.423012)),
      'field1'      => 'lorem',
      'field2'      => 100.99,
      'field3'      => today,
      'field4'      => true
    }

    CartoDB::Connection.delete_row 'table_1', record.id

    records = CartoDB::Connection.records 'table_1'

    records.name.should be == 'table_1'
    records.total_rows.should == 0
    records.rows.should be_empty
  end

  it "should execute a select query and return results" do
    table = CartoDB::Connection.create_table 'table #1'

    50.times do
      CartoDB::Connection.insert_row 'table_1', {
        'name'        => String.random(15),
        'description' => String.random(200),
        'the_geom' => RGeo::GeoJSON.encode(RgeoFactory.point(rand(180), rand(90)))
      }
    end

    results = CartoDB::Connection.query("SELECT * FROM table_1")
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
    created_table = CartoDB::Connection.create_table 'table_with_name'

    table = CartoDB::Connection.table 'table_with_name'
    table.should_not be_nil
    table[:id].should be == created_table[:id]
  end

  it "should return nil when requesting a table which does not exists" do
    expect{CartoDB::Connection.table('non_existing_table')}.to raise_error(CartoDB::Client::Error, /404 - Not found/)
  end

  it "should return errors on invalid queries" do
    expect{results = CartoDB::Connection.query("SELECT 1 FROM non_existing_table")}.to raise_error(CartoDB::Client::Error, /relation "non_existing_table" does not exist/)
  end

  it "should paginate records" do
    table = CartoDB::Connection.create_table 'table #1'

    50.times do
      CartoDB::Connection.insert_row 'table_1', {
        'name'        => String.random(15),
        'description' => String.random(200),
        'the_geom'    => RGeo::GeoJSON.encode(RgeoFactory.point(rand(180), rand(90)))
      }
    end

    records = CartoDB::Connection.records 'table_1', :page => 0, :rows_per_page => 20
    records.total_rows.should be == 50
    records.rows.should have(20).records
    records.rows.first.cartodb_id.should be == 1
    records.rows.last.cartodb_id.should be == 20

    records = CartoDB::Connection.records 'table_1', :page => 1, :rows_per_page => 20
    records.total_rows.should be == 50
    records.rows.should have(20).records
    records.rows.first.cartodb_id.should be == 21
    records.rows.last.cartodb_id.should be == 40

  end
end
