import socket
import threading
import tkinter as tk
from tkinter import messagebox

# Configuration
HOST = '127.0.0.1'
PORT = 65432

clients = []
server_socket = None
is_running = False

def handle_client(conn, addr):
    clients.append(conn)
    try:
        while is_running:
            data = conn.recv(1024)
            if not data:
                break
            
            # Broadcast to all OTHER clients
            for c in clients:
                if c != conn:
                    try:
                        c.sendall(data)
                    except Exception:
                        pass
    except Exception:
        pass
    finally:
        if conn in clients:
            clients.remove(conn)
        try:
            conn.close()
        except:
            pass

def server_loop():
    global server_socket, is_running
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    # Allow address reuse so we don't get 'address already in use' errors if we restart quickly
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    
    try:
        server_socket.bind((HOST, PORT))
        server_socket.listen()
        is_running = True
        
        # Update GUI status safely
        root.after(0, lambda: lbl_status.config(text="SYS: ONLINE", fg="#00FF00"))
        root.after(0, lambda: btn_start.config(state=tk.DISABLED, bg="#333333", fg="#555555"))
        
        while is_running:
            try:
                conn, addr = server_socket.accept()
                threading.Thread(target=handle_client, args=(conn, addr), daemon=True).start()
            except Exception:
                # Exception usually happens when socket is closed during accept()
                break
    except Exception as e:
        root.after(0, lambda: messagebox.showerror("CRITICAL ERROR", str(e)))
    finally:
        is_running = False
        root.after(0, lambda: lbl_status.config(text="SYS: OFFLINE", fg="#FF0033"))
        root.after(0, lambda: btn_start.config(state=tk.NORMAL, bg="#111111", fg="#00FFFF"))

def start_server():
    if not is_running:
        threading.Thread(target=server_loop, daemon=True).start()

def stop_server():
    global is_running, server_socket
    is_running = False
    
    # Disconnect all clients
    for c in clients:
        try:
            c.close()
        except:
            pass
    clients.clear()
    
    # Close the main server socket
    if server_socket:
        try:
            server_socket.close()
        except:
            pass

def close_app():
    stop_server()
    root.destroy()

# Set up the Tkinter GUI
root = tk.Tk()
root.title("NEXUS HUB // Python Relay Server")
root.geometry("320x180")
root.resizable(False, False)
root.configure(bg="#050505")  # Deep black background

# Styling configurations
font_title = ("Courier New", 14, "bold")
font_btn = ("Courier New", 10, "bold")

# UI Elements
# Outer frame for "holographic" border effect
frame_main = tk.Frame(root, bg="#050505", highlightbackground="#00FFFF", highlightthickness=2)
frame_main.pack(expand=True, fill=tk.BOTH, padx=10, pady=10)

lbl_title = tk.Label(frame_main, text="NEXUS RELAY SERVER", bg="#050505", fg="#00FFFF", font=font_title)
lbl_title.pack(pady=(10, 0))

lbl_status = tk.Label(frame_main, text="SYS: OFFLINE", bg="#050505", fg="#FF0033", font=("Courier New", 12, "bold"))
lbl_status.pack(pady=(5, 15))

# Button container for horizontal layout
frame_btns = tk.Frame(frame_main, bg="#050505")
frame_btns.pack()

btn_start = tk.Button(frame_btns, text="INITIATE", command=start_server, width=10, 
                      bg="#111111", fg="#00FFFF", font=font_btn, 
                      activebackground="#00FFFF", activeforeground="#000000", relief=tk.FLAT)
btn_start.grid(row=0, column=0, padx=5)

btn_close = tk.Button(frame_btns, text="TERMINATE", command=close_app, width=10, 
                      bg="#111111", fg="#FF0033", font=font_btn, 
                      activebackground="#FF0033", activeforeground="#000000", relief=tk.FLAT)
btn_close.grid(row=0, column=1, padx=5)

# Handle window close (X button)
root.protocol("WM_DELETE_WINDOW", close_app)

if __name__ == "__main__":
    root.mainloop()
