require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module PackMaterialApp
  class TestConfigRepo < MiniTestWithHooks
    def test_for_selects
      assert_respond_to repo, :for_select_domains
      assert_respond_to repo, :for_select_matres_types
      assert_respond_to repo, :for_select_matres_sub_types
    end

    def test_crud_calls
      assert_respond_to repo, :find_matres_type
      assert_respond_to repo, :create_matres_type
      assert_respond_to repo, :update_matres_type
      assert_respond_to repo, :delete_matres_type

      assert_respond_to repo, :find_matres_sub_type
      assert_respond_to repo, :create_matres_sub_type
      assert_respond_to repo, :update_matres_sub_type
      assert_respond_to repo, :delete_matres_sub_type

      assert_respond_to repo, :find_pm_product
      assert_respond_to repo, :create_pm_product
      assert_respond_to repo, :update_pm_product
      assert_respond_to repo, :delete_pm_product

      assert_respond_to repo, :find_matres_master_list_item
      assert_respond_to repo, :create_matres_master_list_item
      assert_respond_to repo, :update_matres_master_list_item
      assert_respond_to repo, :delete_matres_master_list_item

      assert_respond_to repo, :find_matres_master_list
      assert_respond_to repo, :create_matres_master_list
      assert_respond_to repo, :update_matres_master_list
      assert_respond_to repo, :delete_matres_master_list
    end

    def test_product_code_column_subset
      ConfigRepo.any_instance.stubs(:for_select_material_resource_product_columns).returns([['a', 1], ['a', 2], ['a', 3], ['a', 5], ['a', 6]])
      assert_equal [['a', 1], ['a', 2], ['a', 3]], repo.product_code_column_subset([1, 2, 3])
    end

    def test_for_select_configured_sub_types
      dom = DB[:material_resource_domains].where(domain_name: PackMaterialApp::DOMAIN_NAME).first
      dom_id = dom ? dom[:id] : nil
      type_id1 = DB[:material_resource_types].insert(
        material_resource_domain_id: dom_id,
        type_name: 'type one',
        short_code: 'T1',
        description: 'This is the description field'
      )
      sub_id1 = DB[:material_resource_sub_types].insert(
        material_resource_type_id: type_id1,
        sub_type_name: '1 sub type one',
        short_code: 'SC',
        active: true,
        product_code_ids: '{1,2,3}'
      )
      sub_id2 = DB[:material_resource_sub_types].insert(
        material_resource_type_id: type_id1,
        sub_type_name: '1 sub type two',
        short_code: 'SC',
        active: true,
        product_code_ids: nil
      )
      type_id2 = DB[:material_resource_types].insert(
        material_resource_domain_id: dom_id,
        type_name: 'type two',
        short_code: 'T2',
        description: 'This is the description field'
      )
      sub_id3 = DB[:material_resource_sub_types].insert(
        material_resource_type_id: type_id2,
        sub_type_name: '2 sub type one',
        short_code: 'SC',
        active: true,
        product_code_ids: '{1,2,3}'
      )
      sub_id4 = DB[:material_resource_sub_types].insert(
        material_resource_type_id: type_id2,
        sub_type_name: '2 sub type two',
        short_code: 'SC',
        active: false,
        product_code_ids: '{1,2,3}'
      )
      dom_id2 = DB[:material_resource_domains].insert(
        domain_name: 'Other domain',
        product_table_name: 'other table name',
        variant_table_name: 'other variant table name'
      )
      other_type_id = DB[:material_resource_types].insert(
        material_resource_domain_id: dom_id2,
        type_name: 'type name',
        short_code: 'T3',
        description: 'This is the description field'
      )
      other_sub_id = DB[:material_resource_sub_types].insert(
        material_resource_type_id: other_type_id,
        sub_type_name: 'sub type name',
        short_code: 'SC',
        active: true,
        product_code_ids: '{1,2,3}'
      )

      y = ConfigRepo.new.for_select_configured_sub_types(PackMaterialApp::DOMAIN_NAME)
      expected = { 'T1' => [['1 sub type one', sub_id1]], 'T2' => [['2 sub type one', sub_id3]] }
      assert_equal(expected, y)
    end

    def test_find_matres_type
      dom_id = DB[:material_resource_domains].insert(
        domain_name: 'domain name',
        internal_seq: 10,
        product_table_name: 'product table name',
        variant_table_name: 'variant table name'
      )
      type_id = DB[:material_resource_types].insert(
        material_resource_domain_id: dom_id,
        internal_seq: 1,
        type_name: 'type name',
        short_code: 'SC',
        description: 'This is the description field'
      )

      y = ConfigRepo.new.find_matres_type(type_id)
      assert_instance_of(PackMaterialApp::MatresType, y)
      assert_equal(y.domain_name, 'domain name')
      assert_equal(y.id, type_id)

      DB[:material_resource_types].where(id: type_id).delete
      y = ConfigRepo.new.find_matres_type(type_id)
      assert_nil y

      DB[:material_resource_domains].where(id: dom_id).delete
    end

    def update_matres_type
      dom_id = DB[:material_resource_domains].insert(
        domain_name: 'domain name',
        internal_seq: 10,
        product_table_name: 'product table name',
        variant_table_name: 'variant table name'
      )
      type_id = DB[:material_resource_types].insert(
        material_resource_domain_id: dom_id,
        internal_seq: 1,
        type_name: 'type name',
        short_code: 'SC',
        description: 'This is the description field'
      )

      attrs = { description: 'This is the updated description', measurement_units: [] }
      ConfigRepo.new.update_matres_type(type_id, attrs)
      assert_equal('This is the updated description', DB[:material_resource_types].where(id: type_id).select(:description))

      each_id = DB[:measurement_units].insert(unit_of_measure: 'each')
      pallets_id = DB[:measurement_units].insert(unit_of_measure: 'pallets')
      bags_id = DB[:measurement_units].insert(unit_of_measure: 'bags')
      attrs = { measurement_units: [each_id, pallets_id, bags_id] }
      ConfigRepo.new.update_matres_type(type_id, attrs)
      x = DB[:measurement_units_for_matres_types]
          .where(material_resource_type_id: type_id)
          .select_map(:measurement_unit_id)

      assert_equal [each_id, pallets_id, bags_id], x
    end

    def test_measurement_units
      DB[:measurement_units].insert(unit_of_measure: 'each') # each_id
      DB[:measurement_units].insert(unit_of_measure: 'pallets') # pallets_id
      DB[:measurement_units].insert(unit_of_measure: 'bags') # bags_id

      y = ConfigRepo.new.measurement_units
      assert_equal y, %w[each pallets bags]

      DB[:measurement_units].delete
      y = ConfigRepo.new.measurement_units
      assert_equal y, []
    end

    def test_matres_type_measurement_units_and_ids
      dom_id = DB[:material_resource_domains].insert(
        domain_name: 'domain name',
        internal_seq: 10,
        product_table_name: 'product table name',
        variant_table_name: 'variant table name'
      )
      type_id = DB[:material_resource_types].insert(
        material_resource_domain_id: dom_id,
        internal_seq: 1,
        type_name: 'type name',
        short_code: 'SC',
        description: 'This is the description field'
      )
      each_id = DB[:measurement_units].insert(unit_of_measure: 'each')
      pallets_id = DB[:measurement_units].insert(unit_of_measure: 'pallets')
      bags_id = DB[:measurement_units].insert(unit_of_measure: 'bags')
      DB[:measurement_units_for_matres_types].insert(
        material_resource_type_id: type_id,
        measurement_unit_id: each_id
      )
      DB[:measurement_units_for_matres_types].insert(
        material_resource_type_id: type_id,
        measurement_unit_id: pallets_id
      )
      DB[:measurement_units_for_matres_types].insert(
        material_resource_type_id: type_id,
        measurement_unit_id: bags_id
      )
      y = ConfigRepo.new.matres_type_measurement_units(type_id)
      assert_equal y, %w[each pallets bags]

      y = ConfigRepo.new.matres_type_measurement_unit_ids(type_id)
      assert_equal y, [each_id, pallets_id, bags_id]

      DB[:measurement_units_for_matres_types].where(material_resource_type_id: type_id).delete
      y = ConfigRepo.new.matres_type_measurement_units(type_id)
      assert_equal y, []
      y = ConfigRepo.new.matres_type_measurement_unit_ids(type_id)
      assert_equal y, []
    end

    def test_create_matres_type_unit
      dom_id = DB[:material_resource_domains].insert(
        domain_name: 'domain name',
        internal_seq: 10,
        product_table_name: 'product table name',
        variant_table_name: 'variant table name'
      )
      type_id = DB[:material_resource_types].insert(
        material_resource_domain_id: dom_id,
        internal_seq: 1,
        type_name: 'type name',
        short_code: 'SC',
        description: 'This is the description field'
      )

      ConfigRepo.new.create_matres_type_unit(type_id, 'test unit')
      unit_id = DB[:measurement_units].where(unit_of_measure: 'test unit').select_map(:id)
      refute_nil unit_id
      link_id = DB[:measurement_units_for_matres_types].where(material_resource_type_id: type_id).select_map(:measurement_unit_id)
      assert_equal link_id, unit_id
    end

    def test_add_matres_type_unit
      dom_id = DB[:material_resource_domains].insert(
        domain_name: 'domain name',
        internal_seq: 10,
        product_table_name: 'product table name',
        variant_table_name: 'variant table name'
      )
      type_id = DB[:material_resource_types].insert(
        material_resource_domain_id: dom_id,
        internal_seq: 1,
        type_name: 'type name',
        short_code: 'SC',
        description: 'This is the description field'
      )
      each_id = DB[:measurement_units].insert(unit_of_measure: 'each')
      DB[:measurement_units].insert(unit_of_measure: 'pallets') # pallets_id
      DB[:measurement_units].insert(unit_of_measure: 'bags') # bags_id

      ConfigRepo.new.add_matres_type_unit(type_id, 'each')
      link_id = DB[:measurement_units_for_matres_types].where(
        material_resource_type_id: type_id,
        measurement_unit_id: each_id
      )
      refute_nil link_id

      assert_raises do
        PackMaterialApp::ConfigRepo.new.add_matres_type_unit(type_id, 'does not exist')
      end
    end

    def test_delete_matres_sub_type
      dom = DB[:material_resource_domains].where(domain_name: PackMaterialApp::DOMAIN_NAME).first
      dom_id = dom ? dom[:id] : nil

      prodcol1 = DB[:material_resource_product_columns].where(column_name: 'unit').first
      id1 = prodcol1 ? prodcol1[:id] : nil
      prodcol2 = DB[:material_resource_product_columns].where(column_name: 'style').first
      id2 = prodcol2 ? prodcol2[:id] : nil
      prodcol3 = DB[:material_resource_product_columns].where(column_name: 'brand_1').first
      id3 = prodcol3 ? prodcol3[:id] : nil

      type_id = DB[:material_resource_types].insert(
        material_resource_domain_id: dom_id,
        internal_seq: 1,
        type_name: 'type name',
        short_code: 'SC',
        description: 'This is the description field'
      )
      sub_id = DB[:material_resource_sub_types].insert(
        material_resource_type_id: type_id,
        internal_seq: 1,
        sub_type_name: 'sub type name',
        short_code: 'SC',
        product_code_ids: "{#{id1},#{id2},#{id3}}"
      )
      # comm_group_id = DB[:commodity_groups].insert(
      #   code: 'group',
      #   description: 'desc'
      # )
      # comm_id1 = DB[:commodities].insert(
      #   commodity_group_id: comm_group_id,
      #   code: 'AP',
      #   hs_code: 'AP',
      #   description: 'desc'
      # )
      # comm_id2 = DB[:commodities].insert(
      #   commodity_group_id: comm_group_id,
      #   code: 'PR',
      #   hs_code: 'PR',
      #   description: 'desc'
      # )
      # var_id = DB[:marketing_varieties].insert(
      #   marketing_variety_code: 'variety'
      # )
      prod_id1 = DB[:pack_material_products].insert(
        material_resource_sub_type_id: sub_id,
        unit: 'unit',
        brand_1: 'brand',
        style: 'style'
      )
      prod_id2 = DB[:pack_material_products].insert(
        material_resource_sub_type_id: sub_id,
        unit: 'units',
        brand_1: 'brands',
        style: 'styles'
      )

      x = ConfigRepo.new.delete_matres_sub_type(sub_id)
      refute x.success

      DB[:pack_material_products].where(id: [prod_id1, prod_id2]).delete
      x = ConfigRepo.new.delete_matres_sub_type(sub_id)
      assert x.success
      assert_nil ConfigRepo.new.find_matres_sub_type(sub_id)
    end

    def test_product_variant_columns
      dom_id = DB[:material_resource_domains].insert(
        domain_name: 'domain name',
        internal_seq: 10,
        product_table_name: 'product table name',
        variant_table_name: 'variant table name'
      )
      other_dom_id = DB[:material_resource_domains].insert(
        domain_name: 'other domain name',
        internal_seq: 11,
        product_table_name: 'some table name',
        variant_table_name: 'other table name'
      )
      id1 = DB[:material_resource_product_columns].insert(
        material_resource_domain_id: dom_id,
        column_name: 'column name one',
        short_code: 'CN1'
      )
      id2 = DB[:material_resource_product_columns].insert(
        material_resource_domain_id: dom_id,
        column_name: 'column name two',
        short_code: 'CN2'
      )
      id3 = DB[:material_resource_product_columns].insert(
        material_resource_domain_id: dom_id,
        column_name: 'column name three',
        short_code: 'CN3'
      )
      id4 = DB[:material_resource_product_columns].insert(
        material_resource_domain_id: other_dom_id,
        column_name: 'other column',
        short_code: 'CN3'
      )
      type_id = DB[:material_resource_types].insert(
        material_resource_domain_id: dom_id,
        internal_seq: 1,
        type_name: 'type name',
        short_code: 'SC',
        description: 'This is the description field'
      )
      sub_id = DB[:material_resource_sub_types].insert(
        material_resource_type_id: type_id,
        internal_seq: 1,
        sub_type_name: 'sub type name',
        short_code: 'SC',
        product_code_ids: "{#{id1}}",
        product_column_ids: "{#{id1},#{id2},#{id3}}"
      )

      y = ConfigRepo.new.product_variant_columns(sub_id)
      assert_equal([['column name two', id2], ['column name three', id3]], y)

      DB[:material_resource_sub_types].where(id: sub_id).delete
      y = ConfigRepo.new.product_variant_columns(sub_id)
      assert_equal([], y)
    end

    def test_product_code_columns
      # dom = create_dom
      # id1 = create_pc(dom, seq=1)
      # id2 = create_pc(dom, seq=2)
      # typ = create_type(dom)
      # sub = create_subtype(typ, prod_ids = [id1,id2])
      dom_id = DB[:material_resource_domains].insert(
        domain_name: 'domain name',
        internal_seq: 10,
        product_table_name: 'product table name',
        variant_table_name: 'variant table name'
      )
      id1 = DB[:material_resource_product_columns].insert(
        material_resource_domain_id: dom_id,
        column_name: 'column name one',
        short_code: 'CN1'
      )
      id2 = DB[:material_resource_product_columns].insert(
        material_resource_domain_id: dom_id,
        column_name: 'column name two',
        short_code: 'CN2'
      )
      id3 = DB[:material_resource_product_columns].insert(
        material_resource_domain_id: dom_id,
        column_name: 'column name three',
        short_code: 'CN3'
      )
      type_id = DB[:material_resource_types].insert(
        material_resource_domain_id: dom_id,
        internal_seq: 1,
        type_name: 'type name',
        short_code: 'SC',
        description: 'This is the description field'
      )
      sub_id = DB[:material_resource_sub_types].insert(
        material_resource_type_id: type_id,
        internal_seq: 1,
        sub_type_name: 'sub type name',
        short_code: 'SC',
        product_code_ids: "{#{id1},#{id2},#{id3}}"
      )

      y = ConfigRepo.new.product_code_columns(sub_id)
      assert_equal(y, [['column name one', id1], ['column name two', id2], ['column name three', id3]])
    end

    def test_update_product_code_configuration
      # create_sub => {dom: {id: 1, type: {id: 2, sub: {id: 3}}}}
      dom_id = DB[:material_resource_domains].insert(
        domain_name: 'domain name',
        internal_seq: 10,
        product_table_name: 'product table name',
        variant_table_name: 'variant table name'
      )
      type_id = DB[:material_resource_types].insert(
        material_resource_domain_id: dom_id,
        internal_seq: 1,
        type_name: 'type name',
        short_code: 'SC',
        description: 'This is the description field'
      )
      sub_id = DB[:material_resource_sub_types].insert(
        material_resource_type_id: type_id,
        internal_seq: 1,
        sub_type_name: 'sub type name',
        short_code: 'SC'
      )
      test_res = { chosen_column_ids: [77, 78, 79], columncodes_sorted_ids: [78, 79, 77] }
      x = ConfigRepo.new.update_product_code_configuration(sub_id, test_res)
      assert_equal(true, x.success)

      matres_sub_type = ConfigRepo.new.find_matres_sub_type(sub_id)
      assert_equal(matres_sub_type.product_column_ids.join(','), '77,78,79')
      assert_equal(matres_sub_type.product_code_ids.join(','), '78,79,77')
    end

    def test_sub_type_master_list_items
      skip 'still todo'
      sub_id = 1
      y = ConfigRepo.new.sub_type_master_list_items(sub_id)
      p y
    end

    # def sub_type_master_list_items(sub_type_id)
    #   DB[get_dataminer_report('matres_prodcol_sub_type_list_items.yml').sql].where(sub_type_id: sub_type_id)
    #
    # end
    #
    # def for_select_sub_type_master_list_items(sub_type_id, product_column)
    #   sub_type_master_list_items(sub_type_id).map do |r|
    #     if r[:column_name] == product_column.to_s && r[:active]
    #       [(r[:short_code] + (r[:long_name] ? ' - ' + r[:long_name] : '')).to_s, r[:id]]
    #     end
    #   end.compact
    # end
    #
    # def get_dataminer_report(file_name)
    #   path = File.join(ENV['ROOT'], 'grid_definitions', 'dataminer_queries', file_name.sub('.yml', '') << '.yml')
    #   rpt_hash = Crossbeams::Dataminer::YamlPersistor.new(path)
    #   Crossbeams::Dataminer::Report.load(rpt_hash)
    # end

    def repo
      ConfigRepo.new
    end
  end
end
