module ApplicationHelper
  def zip_codes_response(zip_codes, options = {})
    {
      zip_codes: zip_codes.map { |zip_code|
        zip_code_response(zip_code)
      }
    }.merge(options)
  end

  def zip_code_response(zip_code)
    {
      id: zip_code.id,
      d_codigo: zip_code.d_codigo,
      d_asenta: zip_code.d_asenta,
      d_tipo_asenta: zip_code.d_tipo_asenta,
      d_mnpio: zip_code.d_mnpio,
      d_estado: zip_code.d_estado,
      d_ciudad: zip_code.d_ciudad,
      d_cp: zip_code.d_cp,
      c_estado: zip_code.c_estado,
      c_oficina: zip_code.c_oficina,
      c_cp: zip_code.c_cp,
      c_tipo_asenta: zip_code.c_tipo_asenta,
      c_mnpio: zip_code.c_mnpio,
      id_asenta_cpcons: zip_code.id_asenta_cpcons,
      d_zona: zip_code.d_zona,
      c_cve_ciudad: zip_code.c_cve_ciudad
    }
  end

  def pagination_json(paginated_array, per_page)
    { pagination: { per_page: per_page.to_i, total_pages: paginated_array.total_pages, total_objects: paginated_array.total_count } }
  end
end
