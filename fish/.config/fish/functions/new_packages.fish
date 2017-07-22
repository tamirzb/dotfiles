function new_packages --argument filename
	set installed (pacman -Qeq)
set old (pacman -Qgq base base-devel)
if test -n "$filename"
set old $old (cat "$filename")
end
comm -23 (echo -s $installed\n | sort | psub) (echo -s $old\n | sort | psub)
end
