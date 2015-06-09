# Garbage-war-VMWare

Тази програма беше написана, за да участва в състезанието Garbage Wars организирано от VMWare. Състезанието беше проведено между съученици и с този код се наредихме на 8-мо място.
Не са използвани готови библиотеки за намирането на пътища. 

	threads = (1..10).map do |number| 	
	Thread.new(number) do |number|
	
Пуска се по една нишка за всеки от десете сектора.

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
		
Целта на тези 20 реда код е да намери всички забранени и сочени от забранени точки. При срещане на забранена точка всички номера след нея се записват в array bad_trajectories.

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
		
В тези редове вече откриваме всички траектории, като когато срещне забранена или сочена от забранена точка пътят се прекъсва.

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
		
Тези редове проверяват и премахват траектории, които вече се съдържат в някоя друга.
Например ако имаме траектория 1 2 3 и траектория 1 2 3 4 5, по късата траектория ще бъде изтрита.
