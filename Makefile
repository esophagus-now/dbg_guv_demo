default:
	vivado -mode tcl -nolog -nojournal -source make_guv_demo.tcl -tclargs dbg_guv_demo xczu19eg-ffvc1760-2-i src

clean:
	rm -rf dbg_guv_demo
	# Vivado sure likes leaving junk on your hard drive...
	rm -rf .Xil
	rm -rf vivado*
	rm -rf *.tmp
