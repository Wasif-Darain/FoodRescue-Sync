import { createContext, useContext, useState, type ReactNode } from 'react';
import type { AccountType, UserMode } from '../types';

interface AuthUser {
  id: number;
  name: string;
  email: string;
  accountType: AccountType;
  mode: UserMode;
}

interface AuthContextType {
  user: AuthUser | null;
  login: (email: string, password: string, accountType: AccountType, name: string) => void;
  logout: () => void;
  toggleMode: () => void;
  isAuthenticated: boolean;
}

const AuthContext = createContext<AuthContextType | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(null);

  const login = (_email: string, _password: string, accountType: AccountType, name: string) => {
    setUser({ id: 1, name, email: _email, accountType, mode: 'donor' });
  };

  const toggleMode = () => {
    if (user) setUser({ ...user, mode: user.mode === 'donor' ? 'consumer' : 'donor' });
  };

  const logout = () => setUser(null);

  return (
    <AuthContext.Provider value={{ user, login, logout, toggleMode, isAuthenticated: !!user }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be inside AuthProvider');
  return ctx;
}
