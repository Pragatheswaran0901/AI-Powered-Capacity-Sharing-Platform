import React, { createContext, useContext, useState, useEffect } from 'react';
import { User, UserRole } from '../types';
import { api } from '../services/api';

interface AuthContextType {
  user: User | null;
  token: string | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<void>;
  switchDemoUser: (roleKey: 'msme' | 'admin' | 'owner' | 'seeker' | 'machine_owner' | 'machine_seeker') => Promise<void>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const DEMO_ACCOUNTS = {
  msme: { email: 'pragatheswaran@machhunt.demo', password: 'password123', name: 'Pragatheswaran', company: 'Kongu Precision Components' },
  owner: { email: 'janika@machhunt.demo', password: 'password123', name: 'Janika', company: 'Kovai Precision Works' },
  seeker: { email: 'karthikeyan@machhunt.demo', password: 'password123', name: 'Karthikeyan', company: 'TamilTech Components' },
  admin: { email: 'admin@machhunt.demo', password: 'password123', name: 'Admin', company: 'Mach-Hunt Platform Admin' },
};

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(localStorage.getItem('machhunt_token'));
  const [loading, setLoading] = useState<boolean>(true);

  useEffect(() => {
    async function initAuth() {
      const storedToken = localStorage.getItem('machhunt_token');
      if (storedToken) {
        const userData = await api.getMe();
        if (userData) {
          setUser({
            id: userData.user_id,
            name: userData.name,
            email: userData.email,
            role: userData.role as UserRole,
            msme_id: userData.msme_id,
            company_name: userData.company_name
          });
        } else {
          localStorage.removeItem('machhunt_token');
          setToken(null);
          setUser(null);
        }
      } else {
        // App starts at login page for unauthenticated visitors
        setUser(null);
      }
      setLoading(false);
    }
    initAuth();
  }, []);

  const login = async (email: string, password: string) => {
    const res = await api.login(email, password);
    setToken(res.access_token);
    setUser({
      id: res.user_id,
      name: res.name,
      email: res.email,
      role: res.role as UserRole,
      msme_id: res.msme_id,
      company_name: res.company_name
    });
  };

  const switchDemoUser = async (roleKey: 'msme' | 'admin' | 'owner' | 'seeker' | 'machine_owner' | 'machine_seeker') => {
    let demoAcc = DEMO_ACCOUNTS.msme;
    if (roleKey === 'admin') demoAcc = DEMO_ACCOUNTS.admin;
    if (roleKey === 'owner' || roleKey === 'machine_owner') demoAcc = DEMO_ACCOUNTS.owner;
    if (roleKey === 'seeker' || roleKey === 'machine_seeker') demoAcc = DEMO_ACCOUNTS.seeker;

    try {
      const res = await api.login(demoAcc.email, demoAcc.password);
      setToken(res.access_token);
      setUser({
        id: res.user_id,
        name: res.name,
        email: res.email,
        role: res.role as UserRole,
        msme_id: res.msme_id,
        company_name: res.company_name
      });
    } catch (e) {
      setUser({
        id: roleKey === 'admin' ? 4 : 1,
        name: demoAcc.name,
        email: demoAcc.email,
        role: roleKey === 'admin' ? 'admin' : 'msme',
        msme_id: 1,
        company_name: demoAcc.company
      });
    }
  };

  const logout = () => {
    localStorage.removeItem('machhunt_token');
    setToken(null);
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, token, loading, login, switchDemoUser, logout }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within an AuthProvider');
  return context;
};

