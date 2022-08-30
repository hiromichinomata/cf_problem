require 'csv'
require 'date'
require 'ipaddr'

n = ARGV[0]&.to_i
m = ARGV[1]&.to_i
t = ARGV[2]&.to_i

csv_data = CSV.read("input.csv")
csv_data.sort!
csv_data = csv_data.filter { |row| row != [] }

# high_load time
high_load_points = {}
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
        from_dt = DateTime.parse(date_list[i])
        to_dt = DateTime.parse(date_list[i+m-1])
        if high_load_points[server_address] == nil
          high_load_points[server_address] = [[from_dt, to_dt]]
        else
          high_load_points[server_address].append([from_dt, to_dt])
        end
      end
    end
  end
end

high_load_points.each do |server_address, from_to_list|
  i = 0
  while i < from_to_list.size
    from_dt_i, to_dt_i = from_to_list[i]

    j = i + 1
    while j < from_to_list.size
      from_dt_j, to_dt_j = from_to_list[j]
      if from_dt_j <= to_dt_i
        to_dt_i = to_dt_j
        i += 1
        j += 1
      else
        break
      end
    end

    to_sec = to_dt_i.to_time.to_i
    from_sec = from_dt_i.to_time.to_i
    high_load_reports.append([server_address, to_sec - from_sec])

    i += 1
  end
end

puts '# high_load time'
high_load_reports.each do |report|
  puts report.join(',')
end

puts

puts '# down time'

# down time
subnet_chunk = csv_data.group_by{|_, server_address, _| IPAddr.new(server_address).to_s }

subnet_chunk.each do |network, network_data|
  incident_servers = {}
  incident_reports = []
  incident_count = {}
  incident_count.default = 0

  switch_incident_count = 0
  switch_incident_start = nil
  switch_incident_reports = []
  prev_address = nil
  network_data.each do |confirm_date, server_address, response_result|
    if response_result == '-'
      if prev_address == server_address
        switch_incident_count = 0
        switch_incident_start = nil
      else
        switch_incident_count += 1
        switch_incident_start = confirm_date if switch_incident_start == nil
      end
    else
      if switch_incident_count >= n
        to_sec = DateTime.parse(confirm_date).to_time.to_i
        from_sec = DateTime.parse(switch_incident_start).to_time.to_i
        switch_incident_reports.append([to_sec - from_sec])
      end
      switch_incident_count = 0
      switch_incident_start = nil
    end
    prev_address = server_address
  end

  if switch_incident_reports.size > 0 && n > 1
    puts "-- switch --: #{network}"
    switch_incident_reports.each do |report|
      puts report
    end
  end

  network_data.each do |confirm_date, server_address, response_result|
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

  if incident_reports.size + incident_servers.size > 0
    puts "-- network: #{network} --"
  end

  incident_reports.each do |report|
    puts report.join(',')
  end

  incident_servers.each do |server_address, confirm_date|
    if incident_count[server_address] >= n
      puts "#{server_address},inf"
    end
  end
end
