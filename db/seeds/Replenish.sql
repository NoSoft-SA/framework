
INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('Replenish', 1, (SELECT id FROM functional_areas
WHERE functional_area_name = 'Pack Material'));


INSERT INTO programs_webapps(program_id, webapp) VALUES (
  (SELECT id FROM programs
  WHERE program_name = 'Replenish'
        AND functional_area_id = (SELECT id FROM functional_areas
  WHERE functional_area_name = 'Pack Material')),
  'Framework');

-- NEW menu item

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Replenish'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Pack Material')),
        'New Purchase Order', '/pack_material/replenish/mr_purchase_orders/new', 1);


-- LIST menu item
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Replenish'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Pack Material')),
        'Purchase Orders', '/list/mr_purchase_orders', 2);

INSERT INTO address_types (address_type) VALUES ('Delivery Address');


-- LIST menu item
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Replenish'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Pack Material')),
        'Delivery Terms', '/list/mr_delivery_terms', 2);