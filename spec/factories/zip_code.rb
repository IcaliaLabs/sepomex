# frozen_string_literal: true

FactoryBot.define do
  factory :zip_code do
    d_codigo { '01000' }
    d_asenta { 'San Ángel' }
    d_tipo_asenta { 'Colonia' }
    d_mnpio { 'Álvaro Obregón' }
    d_estado { 'Ciudad de México' }
    d_ciudad { 'Ciudad de México' }
    d_cp { '01001' }
    c_estado { '09' }
    c_oficina { '01001' }
    c_cp { '.' }
    c_tipo_asenta { '09' }
    c_mnpio { '010' }
    id_asenta_cpcons { '0001' }
    d_zona { 'Urbano' }
    c_cve_ciudad { '01' }
  end
end
