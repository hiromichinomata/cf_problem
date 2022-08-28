require 'csv'
require 'date'

n = ARGV[0]&.to_i
m = ARGV[1]&.to_i
t = ARGV[2]&.to_i

csv_data = CSV.read("input.csv")
csv_data.sort!

# high_load time
high_load_reports = []

address_date_to_response = {}
server_logs = {}

csv_data.each do |confirm_date, server_address, response_result|
  next if confirm_date == nil

  if address_date_to_response[server_address] == nil
    address_date_to_response[server_address] = {}
  end
  address_date_to_response[server_address][confirm_date] = response_result

  if server_logs[server_address] == nil
    next if response_result == '-'

    server_logs[server_address] = [[confirm_date]]
  else
    if response_result == '-'
      server_logs[server_address].append([])
    else
      server_logs[server_address][-1].append(confirm_date)
    end
  end
end

server_logs.keys.each do |server_address|
  server_logs[server_address] = server_logs[server_address].select { |arr| arr != [] }
end

server_logs.each do |server_address, log_arr|
  log_arr.each do |date_list|
    response_list = date_list.map{ |date| address_date_to_response[server_address][date].to_i }
    (0...(date_list.size-m+1)).each do |i|
      if response_list[i...i+m].sum/m.to_f >= t
        from_sec = DateTime.parse(date_list[i]).to_time.to_i
        to_sec = DateTime.parse(date_list[i+m-1]).to_time.to_i
        high_load_reports.append([server_address, to_sec - from_sec])
      end
    end
  end
end

puts '# high_load time'
high_load_reports.each do |report|
  puts report.join(',')
end

puts

# down time
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

puts '# down time'
incident_reports.each do |report|
  puts report.join(',')
end

incident_servers.each do |server_address, confirm_date|
  if incident_count[server_address] >= n
    puts "#{server_address},inf"
  end
end
