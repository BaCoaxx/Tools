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
        root.after(0, lambda: lbl_status.config(text="Status: Running", fg="green"))
        root.after(0, lambda: btn_start.config(state=tk.DISABLED))
        
        while is_running:
            try:
                conn, addr = server_socket.accept()
                threading.Thread(target=handle_client, args=(conn, addr), daemon=True).start()
            except Exception:
                # Exception usually happens when socket is closed during accept()
                break
    except Exception as e:
        root.after(0, lambda: messagebox.showerror("Server Error", str(e)))
    finally:
        is_running = False
        root.after(0, lambda: lbl_status.config(text="Status: Stopped", fg="red"))
        root.after(0, lambda: btn_start.config(state=tk.NORMAL))

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
root.title("Python Walkie-Talkie Server")
root.geometry("300x150")
root.resizable(False, False)

# UI Elements
lbl_status = tk.Label(root, text="Status: Stopped", fg="red", font=("Arial", 12, "bold"))
lbl_status.pack(pady=15)

btn_start = tk.Button(root, text="Start Server", command=start_server, width=15, font=("Arial", 10))
btn_start.pack(pady=5)

btn_close = tk.Button(root, text="Close", command=close_app, width=15, font=("Arial", 10))
btn_close.pack(pady=5)

# Handle window close (X button)
root.protocol("WM_DELETE_WINDOW", close_app)

if __name__ == "__main__":
    root.mainloop()
