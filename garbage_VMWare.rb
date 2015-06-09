#gem install rest-open-uri

require 'open-uri'
require 'net/http'

HOST_URL="http://172.16.18.230:8080"

def get_objects objects, number
	objects_api = "/api/sector/#{number}/objects"
	url = HOST_URL + objects_api
	open("#{url}", :read_timeout => 10) { |f| f.each_line {|line| objects << line.strip} }
end

def get_roots roots, number
	roots_api = "/api/sector/#{number}/roots"
	url = HOST_URL + roots_api
	open("#{url}", :read_timeout => 10) { |f| f.each_line {|line| roots << line.strip} }
end

def collect_garbage boklik, number
	collect_api = "/api/sector/#{number}/company/boklici/trajectory"
	url = URI(HOST_URL + collect_api)
	res = Net::HTTP.post_form(url, 'trajectory' => boklik, :read_timeout => 10)
	puts res.body
end

threads = (1..10).map do |number| 	
	Thread.new(number) do |number|
		edges = Array.new
		first = Array.new
		second = Array.new
		path = Array.new
		trajectories = Array.new
		bad_trajectories = Array.new
		indexes = Array.new

		get_objects edges, number
		get_roots bad_trajectories, number

		edges.each do |line|
			first << line.split(" ").first
			second << line.split(" ").last
		end

		f_hash = Hash[first.map.with_index.to_a] # Намира индекса елемента във first
		s_hash = Hash[second.map.with_index.to_a] # Намира индекса елемента във second
		i = 0
		first.each do |first_num|
			indexes.clear
			first_num = first[i]
			second_num = second[i]
			index = f_hash[second_num]
			indexx = s_hash[second_num]
			if bad_trajectories.include?(second_num) || bad_trajectories.include?(first_num)
				if bad_trajectories.include?(first_num)
					bad_trajectories << second_num
					second_num = second[indexx]
				end
				while first.include?(second_num) && !indexes.include?(index)  do
					bad_trajectories << first[index] << second[index]
					second_num = second[index]
					index = f_hash[second_num]
					indexes << index					
				end
			end
			i += 1
		end
		i = 0
		first.each do |first_num|
			second_num = second[i]
			index = f_hash[second_num]
			path << first[i] if !bad_trajectories.include?(first[i])
			path << second[i] if !bad_trajectories.include?(second[i])
			if index && !bad_trajectories.include?(second[index])
				second_num = second[index]
				path << second[index]
				boolean = 1
				while first.include?(second_num) && boolean == 1 do
					if index && !bad_trajectories.include?(second[index])
						index = f_hash[second_num] # Търси индекса във first
						if path.include?(second[index])
							if first[index-1] == first[index] && !path.include?(second[index-1]) then path << second_num = second[index-1] 
							elsif first[index+1] == first[index] && !path.include?(second[index-1]) then path << second_num = second[index+1] 
							else boolean = 0 end
							index = f_hash[second_num]
						end
						path << second[index] if index && !bad_trajectories.include?(second[index]) && !path.include?(second[index])
						second_num = second[index] if index
						indexes << index if index
					else boolean = 0
					end
				end
			end
			trajectories << path
			path = Array.new
			i += 1
		end
		trajectories = trajectories.uniq
		trajectories = trajectories.sort_by {|x| x.length}.reverse

		trajectories.each do |trajectory1| 
			trajectory1_1 = trajectory1.join(" ")
			trajectories.each do |trajectory2|
				trajectory2_2 = trajectory2.join(" ")
				if trajectory1_1.include?(trajectory2_2) && trajectory1_1 != trajectory2_2 && trajectory1_1.length > trajectory2_2.length
					trajectories.delete(trajectory2) 
				elsif trajectory2_2.include?(trajectory1_1) && trajectory1_1 != trajectory2_2 && trajectory1.length < trajectory2_2.length
					trajectories.delete(trajectory1) 
				end
			end
		end

		trajectories.each do |trajectory| 
			collect_garbage trajectory.join(' '), number 
		end
	end
end
threads.each { |t|	t.join }