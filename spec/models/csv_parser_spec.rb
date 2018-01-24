require "rails_helper"
require 'tempfile'

RSpec.describe CSVParser, type: :model do
  let(:path) { "public/session_history.csv" }
  subject { CSVParser.new(path) }
  let(:data) { subject.instance_variable_get("@csv_data") }
  # 
  # it "included CsvParserHelper" do
  #   expect(subject).to be_a(CsvParserHelper)
  # end

  context "for csv data" do
    let(:text) {
      "created_at,passed_tests_count,failed_tests_count,worker_time,bundle_time\n"\
      "01/01/2015,1,1,4,6\n"\
      "01/01/2015,2,5,7,3\n"\
      "02/01/2015,4,3,0,0\n"
    }
    let(:path) do
      file = Tempfile.new('temp_csv_file')
      file.write(text)
      file.close
      file.path
    end

    it "parses csv data correctly" do
      expect(data).to eql([{
          "created_at"=>"01/01/2015",
          "passed_tests_count"=>1,
          "failed_tests_count"=>1,
          "worker_time"=>4,
          "bundle_time"=>6
        },{
          "created_at"=>"01/01/2015",
          "passed_tests_count"=>2,
          "failed_tests_count"=>5,
          "worker_time"=>7,
          "bundle_time"=>3
        },{
          "created_at"=>"02/01/2015",
          "passed_tests_count"=>4,
          "failed_tests_count"=>3,
          "worker_time"=>0,
          "bundle_time"=>0
      }])
    end

    it "group csv data by 'created_at' correctly" do
      expect(subject.result_hash).to eql([{
          "created_at"=>"01/01/15",
          "passed_tests_count"=>3,
          "failed_tests_count"=>6,
          "worker_time"=>11,
          "bundle_time"=>9,
          "abnormal"=>true
        },{
          "created_at"=>"01/02/15",
          "passed_tests_count"=>4,
          "failed_tests_count"=>3,
          "worker_time"=>0,
          "bundle_time"=>0,
          "abnormal"=>true
      }])
    end
  end
end
