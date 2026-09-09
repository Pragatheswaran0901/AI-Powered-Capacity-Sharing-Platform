import React, { useState } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import { DemoBanner } from './components/DemoBanner';
import { Navbar } from './components/Navbar';
import { Footer } from './components/Footer';
import { IoTMockModal } from './components/IoTMockModal';

import { LoginPage } from './pages/LoginPage';
import { RegisterPage } from './pages/RegisterPage';
import { Dashboard } from './pages/Dashboard';
import { FindCapacityPage } from './pages/FindCapacityPage';
import { MyMachinesPage } from './pages/MyMachinesPage';
import { AddMachinePage } from './pages/AddMachinePage';
import { MyRequirementsPage } from './pages/MyRequirementsPage';
import { RequirementCreatePage } from './pages/RequirementCreatePage';
import { BookingsPage } from './pages/BookingsPage';
import { AnalyticsPage } from './pages/AnalyticsPage';
import { AdminDashboard } from './pages/AdminDashboard';
import { LandingPage } from './pages/LandingPage';

const ProtectedRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { user, loading } = useAuth();
  if (loading) return <div className="min-h-screen bg-slate-900 text-white flex items-center justify-center">Loading Mach-Hunt...</div>;
  if (!user) return <Navigate to="/login" replace />;
  return <>{children}</>;
};

export const AppContent: React.FC = () => {
  const [showIoTModal, setShowIoTModal] = useState<boolean>(false);
  const { user } = useAuth();

  return (
    <Router>
      <div className="min-h-screen flex flex-col bg-slate-900 text-slate-100 font-sans">
        <DemoBanner />
        <Navbar onOpenIoTModal={() => setShowIoTModal(true)} />

        <main className="flex-1">
          <Routes>
            <Route path="/" element={user ? <Navigate to="/dashboard" replace /> : <Navigate to="/login" replace />} />
            <Route path="/login" element={<LoginPage />} />
            <Route path="/register" element={<RegisterPage />} />

            <Route path="/dashboard" element={<ProtectedRoute><Dashboard /></ProtectedRoute>} />
            <Route path="/find-capacity" element={<ProtectedRoute><FindCapacityPage /></ProtectedRoute>} />
            <Route path="/machines" element={<ProtectedRoute><MyMachinesPage /></ProtectedRoute>} />
            <Route path="/machines/add" element={<ProtectedRoute><AddMachinePage /></ProtectedRoute>} />
            <Route path="/requirements" element={<ProtectedRoute><MyRequirementsPage /></ProtectedRoute>} />
            <Route path="/requirements/new" element={<ProtectedRoute><RequirementCreatePage /></ProtectedRoute>} />
            <Route path="/bookings" element={<ProtectedRoute><BookingsPage /></ProtectedRoute>} />
            <Route path="/analytics" element={<ProtectedRoute><AnalyticsPage /></ProtectedRoute>} />
            <Route path="/overview" element={<LandingPage />} />
          </Routes>
        </main>

        <Footer />

        {showIoTModal && (
          <IoTMockModal onClose={() => setShowIoTModal(false)} />
        )}
      </div>
    </Router>
  );
};

export const App: React.FC = () => {
  return (
    <AuthProvider>
      <AppContent />
    </AuthProvider>
  );
};

export default App;

