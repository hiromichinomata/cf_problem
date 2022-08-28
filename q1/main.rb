require 'csv'
require 'date'

csv_data = CSV.read("input.csv")
csv_data.sort!
incident_servers = {}
incident_reports = []
csv_data.each do |confirm_date, server_address, response_result|
  if response_result == '-' && incident_servers[server_address] == nil
    incident_servers[server_address] = confirm_date
  elsif response_result != '-' && incident_servers[server_address] != nil
    to_sec = DateTime.parse(confirm_date).to_time.to_i
    from_sec = DateTime.parse(incident_servers[server_address]).to_time.to_i
    incident_reports.append([server_address, to_sec - from_sec])

    incident_servers.delete(server_address)
  end
end

incident_reports.each do |report|
  puts report.join(',')
end

incident_servers.each do |server_address, confirm_date|
  puts "#{server_address},inf"
end
