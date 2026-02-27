import subprocess

def run_simulation(
cur1,tar1,diff1,
cur2,tar2,diff2,
cur3,tar3,diff3,
cur4,tar4,diff4,
fat):

    with open("tb_template.v","r") as f:
        tb=f.read()

    tb=tb.replace("{{CUR1}}",str(cur1))
    tb=tb.replace("{{TAR1}}",str(tar1))
    tb=tb.replace("{{DIFF1}}",str(diff1))

    tb=tb.replace("{{CUR2}}",str(cur2))
    tb=tb.replace("{{TAR2}}",str(tar2))
    tb=tb.replace("{{DIFF2}}",str(diff2))

    tb=tb.replace("{{CUR3}}",str(cur3))
    tb=tb.replace("{{TAR3}}",str(tar3))
    tb=tb.replace("{{DIFF3}}",str(diff3))

    tb=tb.replace("{{CUR4}}",str(cur4))
    tb=tb.replace("{{TAR4}}",str(tar4))
    tb=tb.replace("{{DIFF4}}",str(diff4))

    tb=tb.replace("{{FAT}}",str(fat))

    with open("tb_auto.v","w") as f:
        f.write(tb)

    subprocess.run([
        "iverilog",
        "-o","sim.out",
        "priority_engine_advanced.v",
        "tb_auto.v"
    ])

    result=subprocess.run(
        ["vvp","sim.out"],
        capture_output=True,
        text=True
    )

    return result.stdout
