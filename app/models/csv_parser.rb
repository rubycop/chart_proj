require 'csv'

class CSVParser
  include CsvParserHelper

  GROUP_VALUES = [
    "passed_tests_count",
    "failed_tests_count",
    "worker_time",
    "bundle_time"
  ]

  def initialize(path)
    @csv_data = csv_rows_to_hash(path)
  end

  def result_hash(grouping: true)
    return @csv_data unless grouping

    result_arr = []
    group_by_date.each_pair do |date, hash_arr|
      result_arr << create_new_hash(date, hash_arr)
    end

    result_arr
  end

  private

  def create_new_hash(date, hash_arr)
    new_hash = { "created_at" => date }
    GROUP_VALUES.each do |value|
      new_hash[value] = sum_values(hash_arr, value)
    end
    new_hash["abnormal"] = is_abnormal?(new_hash)

    new_hash
  end

  def csv_rows_to_hash(path)
    read_csv_data(path).each_with_object([]) do |row, arr|
      hash_row = row.to_hash

      arr << hash_row
    end
  end

  def group_by_date
    @csv_data.group_by do |data|
      format_date_string(data["created_at"])
    end
  end
end