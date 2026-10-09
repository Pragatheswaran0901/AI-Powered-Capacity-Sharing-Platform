/**
 * Mach-Hunt Web Google Maps Engine
 * Official Google Maps JavaScript API integration for Flutter Web
 */
(function() {
  'use strict';

  let mapInstance = null;
  let activeMarkers = {};
  let currentInfoWindow = null;
  let markersData = {};
  let pendingMarkers = null;
  let currentContainerId = null;
  let mapInitialized = false;

  // View factory helper called from Flutter
  window.machHuntCreateMapContainer = function(viewId) {
    const id = 'mach-hunt-web-map-container';
    let container = document.getElementById(id);
    if (!container) {
      container = document.createElement('div');
      container.id = id;
    }
    container.style.width = '100%';
    container.style.height = '100%';
    container.style.minHeight = '380px';
    container.style.position = 'relative';
    container.style.backgroundColor = '#F8FAFC';
    container.style.borderRadius = '12px';
    container.style.overflow = 'hidden';
    return container;
  };

  function createMarkerIcon(isSelected, matchPercentage) {
    const isHighMatch = matchPercentage && matchPercentage >= 85;
    // Mach-Hunt palette:
    // Selected: #2563EB (Azure Blue), High match: #16A34A (Emerald Green), Normal: #FF6B00 (Mach Orange)
    const fillColor = isSelected ? '#2563EB' : (isHighMatch ? '#16A34A' : '#FF6B00');
    const scale = isSelected ? 12 : 9;

    return {
      path: google.maps.SymbolPath.CIRCLE,
      fillColor: fillColor,
      fillOpacity: 0.95,
      strokeColor: '#FFFFFF',
      strokeWeight: 2.5,
      scale: scale,
    };
  }

  function initMap(containerId, lat, lng, zoom) {
    currentContainerId = containerId || 'mach-hunt-web-map-container';
    const container = document.getElementById(currentContainerId);

    if (!container) {
      setTimeout(function() { initMap(containerId, lat, lng, zoom); }, 150);
      return;
    }

    if (typeof google === 'undefined' || typeof google.maps === 'undefined' || typeof google.maps.Map === 'undefined') {
      console.log('[MachHuntWebMap] Waiting for Google Maps JavaScript API...');
      setTimeout(function() { initMap(containerId, lat, lng, zoom); }, 200);
      return;
    }

    try {
      const centerPos = {
        lat: Number(lat) || 11.0168,
        lng: Number(lng) || 76.9558
      };

      mapInstance = new google.maps.Map(container, {
        center: centerPos,
        zoom: Number(zoom) || 12,
        mapTypeId: 'roadmap',
        mapTypeControl: true,
        streetViewControl: false,
        fullscreenControl: true,
        zoomControl: true,
        styles: [
          {
            featureType: 'poi.business',
            stylers: [{ visibility: 'simplified' }]
          }
        ]
      });

      currentInfoWindow = new google.maps.InfoWindow();

      google.maps.event.addListener(mapInstance, 'click', function() {
        if (currentInfoWindow) currentInfoWindow.close();
      });

      mapInitialized = true;
      console.log('[MachHuntWebMap] Google Map initialized on #' + currentContainerId);

      if (pendingMarkers) {
        updateMarkers(pendingMarkers);
        pendingMarkers = null;
      }
    } catch (e) {
      console.error('[MachHuntWebMap] Initialization error:', e);
      if (window.machHuntOnMapError) {
        window.machHuntOnMapError(String(e.message || e));
      }
    }
  }

  function openInfoWindow(markerId) {
    const m = markersData[markerId];
    const marker = activeMarkers[markerId];
    if (!m || !marker || !mapInstance || !currentInfoWindow) return;

    // Highlight selected marker icon
    for (const id in activeMarkers) {
      const isThis = (id === markerId);
      activeMarkers[id].setIcon(createMarkerIcon(isThis, markersData[id] && markersData[id].matchPercentage));
    }

    const company = m.companyName || m.title || 'Industrial Capacity Provider';
    const industry = m.industry || 'Manufacturing';
    const city = m.city || 'Tamil Nadu';
    const category = m.category || m.title || 'Industrial Machine';
    const rate = m.hourlyPrice ? ('₹' + Math.round(m.hourlyPrice) + '/hr') : 'Rate on request';
    const isAvail = m.isAvailable !== false;
    const provider = m.providerName || m.subtitle || 'Verified MSME Partner';
    const mapsUrl = m.mapsUrl || ('https://www.google.com/maps/search/?api=1&query=' + m.latitude + ',' + m.longitude);
    const matchBadge = m.matchPercentage ? `<span style="background: #EBF5FF; color: #1E40AF; font-size: 10px; font-weight: 700; padding: 2px 7px; border-radius: 12px; margin-left: 6px;">${m.matchPercentage}% Match</span>` : '';

    const contentString = `
      <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; padding: 6px 2px; max-width: 290px; color: #0F172A;">
        <div style="display: flex; align-items: flex-start; justify-content: space-between; gap: 8px; margin-bottom: 6px;">
          <div>
            <div style="font-weight: 700; font-size: 13.5px; color: #0F172A; line-height: 1.25;">${company}</div>
            <div style="font-size: 11px; color: #64748B; margin-top: 2px;">
              🏢 ${industry} • 📍 ${city}
            </div>
          </div>
          <div style="display: flex; flex-direction: column; align-items: flex-end; gap: 4px;">
            <span style="background: ${isAvail ? '#DCFCE7' : '#F1F5F9'}; color: ${isAvail ? '#166534' : '#64748B'}; font-size: 10px; font-weight: 700; padding: 2px 7px; border-radius: 12px; white-space: nowrap;">
              ${isAvail ? 'AVAILABLE' : 'BUSY'}
            </span>
            ${matchBadge}
          </div>
        </div>
        <div style="background: #F8FAFC; border: 1px solid #E2E8F0; border-radius: 6px; padding: 6px 8px; margin-bottom: 8px;">
          <div style="font-size: 11px; color: #334155; font-weight: 600;">
            ⚙️ ${category}
          </div>
          <div style="font-size: 10.5px; color: #64748B; margin-top: 2px;">
            👤 Provider: <span style="font-weight: 600; color: #1E293B;">${provider}</span>
          </div>
          <div style="font-size: 13px; font-weight: 800; color: #FF6B00; margin-top: 4px;">
            ${rate}
          </div>
        </div>
        <div style="display: flex; gap: 6px; margin-top: 8px;">
          <button id="mach-book-${m.id}" onclick="window.machHuntBookCapacity('${m.id}')" style="flex: 1; background: #FF6B00; color: #FFFFFF; border: none; border-radius: 6px; padding: 6px 10px; font-size: 11px; font-weight: 700; cursor: pointer;">
            Book Capacity
          </button>
          <a href="${mapsUrl}" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; justify-content: center; background: #F1F5F9; color: #334155; text-decoration: none; border-radius: 6px; padding: 6px 8px; font-size: 11px; font-weight: 600;">
            Google Maps ↗
          </a>
        </div>
      </div>
    `;

    currentInfoWindow.setContent(contentString);
    currentInfoWindow.open(mapInstance, marker);
  }

  function updateMarkers(markersInput) {
    let markers = markersInput;
    if (typeof markers === 'string') {
      try {
        markers = JSON.parse(markers);
      } catch (e) {
        console.error('[MachHuntWebMap] Error parsing markers JSON:', e);
        return;
      }
    }

    if (!mapInstance || !mapInitialized) {
      pendingMarkers = markers;
      return;
    }

    // Clear old markers
    for (const id in activeMarkers) {
      if (activeMarkers[id]) activeMarkers[id].setMap(null);
    }
    activeMarkers = {};
    markersData = {};

    if (!markers || !markers.length) return;

    const bounds = new google.maps.LatLngBounds();
    let validCount = 0;

    markers.forEach(function(m) {
      const lat = Number(m.latitude);
      const lng = Number(m.longitude);

      if (isNaN(lat) || isNaN(lng) || lat === 0 || lng === 0) {
        console.warn('[MachHuntWebMap] Safely skipping invalid coordinate record:', m.title || m.id);
        return;
      }

      markersData[m.id] = m;
      const pos = { lat: lat, lng: lng };
      bounds.extend(pos);
      validCount++;

      const marker = new google.maps.Marker({
        position: pos,
        map: mapInstance,
        title: (m.companyName || m.title) + ' (' + (m.category || '') + ')',
        icon: createMarkerIcon(false, m.matchPercentage),
        animation: google.maps.Animation.DROP,
      });

      marker.addListener('click', function() {
        openInfoWindow(m.id);
        if (window.machHuntOnMarkerSelected) {
          window.machHuntOnMarkerSelected(m.id);
        }
      });

      activeMarkers[m.id] = marker;
    });

    if (validCount > 1) {
      mapInstance.fitBounds(bounds, { top: 40, bottom: 40, left: 40, right: 40 });
    } else if (validCount === 1) {
      mapInstance.setCenter(bounds.getCenter());
      mapInstance.setZoom(13);
    }

    console.log('[MachHuntWebMap] Successfully placed ' + validCount + ' capacity markers');
  }

  function selectMarker(markerId) {
    if (!markerId) {
      if (currentInfoWindow) currentInfoWindow.close();
      for (const id in activeMarkers) {
        activeMarkers[id].setIcon(createMarkerIcon(false, markersData[id] && markersData[id].matchPercentage));
      }
      return;
    }

    const marker = activeMarkers[markerId];
    if (!marker || !mapInstance) return;

    mapInstance.panTo(marker.getPosition());
    if (mapInstance.getZoom() < 13) {
      mapInstance.setZoom(13.5);
    }
    openInfoWindow(markerId);
  }

  function panTo(lat, lng, zoom) {
    if (!mapInstance) return;
    const target = { lat: Number(lat), lng: Number(lng) };
    mapInstance.panTo(target);
    if (zoom) mapInstance.setZoom(Number(zoom));
  }

  // Global booking action dispatcher from InfoWindow
  window.machHuntBookCapacity = function(id) {
    if (window.machHuntOnBookCapacity) {
      window.machHuntOnBookCapacity(id);
    }
  };

  // Expose global controller
  window.MachHuntWebMap = {
    initMap: initMap,
    updateMarkers: updateMarkers,
    selectMarker: selectMarker,
    panTo: panTo,
    openInfoWindow: openInfoWindow
  };
})();
