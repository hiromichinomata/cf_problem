require 'csv'
require 'date'

n = ARGV[0]&.to_i
csv_data = CSV.read("input.csv")
csv_data.sort!

incident_servers = {}
incident_reports = []
incident_count = {}
incident_count.default = 0

csv_data.each do |confirm_date, server_address, response_result|
  if response_result == '-'
    if incident_servers[server_address] == nil
      incident_servers[server_address] = confirm_date
    end

    incident_count[server_address] += 1
  else
    if incident_servers[server_address] != nil
      if incident_count[server_address] >= n
        to_sec = DateTime.parse(confirm_date).to_time.to_i
        from_sec = DateTime.parse(incident_servers[server_address]).to_time.to_i
        incident_reports.append([server_address, to_sec - from_sec])
      end

      incident_servers.delete(server_address)
      incident_count.delete(server_address)
    end
  end
end

incident_reports.each do |report|
  puts report.join(',')
end

incident_servers.each do |server_address, confirm_date|
  if incident_count[server_address] >= n
    puts "#{server_address},inf"
  end
end
