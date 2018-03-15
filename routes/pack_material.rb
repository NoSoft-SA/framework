# frozen_string_literal: true

Dir['./routes/pack_material/*.rb'].each { |f| require f }

class Framework < Roda
  route('pack_material') do |r|
    r.multi_route('pack_material')
  end
end