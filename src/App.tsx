import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';

import { WelcomeScreen } from './pages/WelcomeScreen';
import { LoginRegister } from './pages/LoginRegister';

import { DonorDashboard } from './pages/donor/DonorDashboard';
import { AddInventory } from './pages/donor/AddInventory';
import { ExpiryTracker } from './pages/donor/ExpiryTracker';
import { CreateListing } from './pages/donor/CreateListing';
import { ListingImageManager } from './pages/donor/ListingImageManager';
import { DonationLog } from './pages/donor/DonationLog';

import { BulkRequest } from './pages/organization/BulkRequest';

import { SurplusRadar } from './pages/shared/SurplusRadar';
import { RequestStatusTracker } from './pages/shared/RequestStatusTracker';
import { PickupCoordination } from './pages/shared/PickupCoordination';
import { NotificationCenter } from './pages/shared/NotificationCenter';
import { ProfileSettings } from './pages/shared/ProfileSettings';

import { ConsumerMarketplace } from './pages/consumer/ConsumerMarketplace';

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { isAuthenticated } = useAuth();
  if (!isAuthenticated) return <Navigate to="/login" replace />;
  return <>{children}</>;
}

function AppRoutes() {
  const { isAuthenticated, user } = useAuth();

  return (
    <Routes>
      <Route path="/" element={
        isAuthenticated
          ? <Navigate to={user?.mode === 'donor' ? '/donor' : '/consumer'} replace />
          : <WelcomeScreen />
      } />
      <Route path="/login" element={<LoginRegister />} />

      {/* Donor mode routes */}
      <Route path="/donor" element={<ProtectedRoute><DonorDashboard /></ProtectedRoute>} />
      <Route path="/donor/inventory" element={<ProtectedRoute><AddInventory /></ProtectedRoute>} />
      <Route path="/donor/expiry" element={<ProtectedRoute><ExpiryTracker /></ProtectedRoute>} />
      <Route path="/donor/create-listing" element={<ProtectedRoute><CreateListing /></ProtectedRoute>} />
      <Route path="/donor/images" element={<ProtectedRoute><ListingImageManager /></ProtectedRoute>} />
      <Route path="/donor/donation-log" element={<ProtectedRoute><DonationLog /></ProtectedRoute>} />

      {/* Consumer mode routes */}
      <Route path="/consumer" element={<ProtectedRoute><ConsumerMarketplace /></ProtectedRoute>} />
      <Route path="/consumer/radar" element={<ProtectedRoute><SurplusRadar /></ProtectedRoute>} />
      <Route path="/consumer/bulk-request" element={<ProtectedRoute><BulkRequest /></ProtectedRoute>} />
      <Route path="/consumer/requests" element={<ProtectedRoute><RequestStatusTracker /></ProtectedRoute>} />
      <Route path="/consumer/pickups" element={<ProtectedRoute><PickupCoordination /></ProtectedRoute>} />

      {/* Shared routes */}
      <Route path="/notifications" element={<ProtectedRoute><NotificationCenter /></ProtectedRoute>} />
      <Route path="/profile" element={<ProtectedRoute><ProfileSettings /></ProtectedRoute>} />

      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <AppRoutes />
      </BrowserRouter>
    </AuthProvider>
  );
}
