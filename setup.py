from threading import Thread
import subprocess
import os

class Installeur(Thread):
    def __init__(self, id, scripts, master,brex_install):
        Thread.__init__(self)
        self.id = id
        self.scripts = scripts
        self.master = master
        self.brex = brex_install

    def run(self):
        subprocess.call("./setup_connections.sh -n " + str(self.id) +
                        (" -m " + str(self.id)) if self.master else "",
                        shell=True,
                        cwd="./connection")

        for script in self.scripts:
            subprocess.call("./provision.sh -n " + str(self.id) + " -p " + script,
                            shell=True,
                            cwd="./provision")
        if self.brex :
            subprocess.call("./set_brex.sh -n " + str(self.id),
                        shell=True,
                        cwd="./management")
        print("Installation finie sur la machine " + str(self.id))


def read_number():
    inp = raw_input()
    machines = []
    while inp != "":
        inp_machines = inp.split("..")
        if len(inp_machines) == 2:
            n1 = int(inp_machines[0])
            n2 = int(inp_machines[1])
            machines.extend(range(n1, n2 + 1))
        else:
            machines.append(int(inp_machines[0]))
        inp = raw_input()
    return inp_machines



os.path.dirname(os.path.realpath(__file__))
print("Machines sur lesquelles executer l'install (Soit un nombre par ligne soit 1..4)")
install = read_number()
print("Machines sur lesquelles donner un acces aux autres machines (Soit un nombre par ligne soit 1..4)")
masters = read_number()
print("Scripts d'install a executer (separer par une virgule)")
scripts = raw_input().split(",")
print("Voulez vous installer l'interface br_ex y/n")
install_brex = raw_input().lower() == 'y'



install_running = []
for m in install:
    install_running.append(Installeur(m, scripts, m in masters,install_brex))

for thread in install_running:
    thread.start()

for thread in install_running:
    thread.join()

print("Installation finie sur les machines " + str(install))
