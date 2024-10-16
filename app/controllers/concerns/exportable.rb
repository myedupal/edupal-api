module Exportable
  extend ActiveSupport::Concern

  def generate_csv(records, headers, attributes)
    CSV.generate(headers: true, quote_empty: true, force_quotes: true) do |csv|
      csv << headers
      if records.respond_to?(:find_each)
        records.find_each do |record|
          csv << attributes.map { |attr| record.send(attr) }
        end
      else
        records.each do |record|
          csv << attributes.map { |attr| record.send(attr) }
        end
      end
    end
  end

  def enumerate_csv(records, headers, attributes, &inject)
    csv_options = { headers: true, quote_empty: true, force_quotes: true }
    Enumerator.new do |row|
      row << CSV::Row.new(headers, headers, csv_options: csv_options).to_s
      convert_record = lambda do |record|
        row_result = attributes.map do |attr|
          # split the attribute by '.' to traverse nested attributes
          # inject(record) to set record as default memo
          result = attr.split('.').inject(record) do |memo, substring|
            # if the current memo chain responds to substring then continue
            # otherwise nil is implicitly returned
            memo.send(substring) if memo.respond_to?(substring)
          end
          result = result.join(", ") if result.is_a?(Array)
          result
        end
        row_result.concat(inject.call(record) || []) if inject

        CSV::Row.new(headers, row_result, csv_options: csv_options).to_s
      end

      if records.respond_to?(:find_each)
        records.find_each { |record| row << convert_record.call(record) }
      else
        records.each { |record| row << convert_record.call(record) }
      end
    end
  end

  def stream_csv(enumerator, filename)
    headers.delete("Content-Length")
    headers["Cache-Control"] = "no-cache"
    headers["Content-Type"] = "text/csv"
    headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
    headers["X-Accel-Buffering"] = "no"

    response.status = 200

    self.response_body = enumerator
  end
end
